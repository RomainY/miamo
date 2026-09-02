import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fiche produit Open Food Facts, réduite aux champs exploités par Miamo.
class OffProduit {
  final String code;
  final String? nom;
  final List<String> categoriesTags;
  final String? quantiteBrute;

  const OffProduit({
    required this.code,
    required this.nom,
    required this.categoriesTags,
    required this.quantiteBrute,
  });
}

enum OffStatut {
  /// Fiche trouvée (éventuellement incomplète).
  trouve,

  /// Code valide mais inconnu de la base Open Food Facts.
  inconnu,

  /// Réseau indisponible, délai dépassé, ou réponse illisible.
  indisponible,
}

class OffResultat {
  final OffStatut statut;
  final OffProduit? produit;

  const OffResultat(this.statut, [this.produit]);
}

/// Recherche d'un produit par code-barres. Abstrait pour être remplacé par un
/// faux en test (aucun appel réseau).
abstract class OpenFoodFactsService {
  Future<OffResultat> rechercher(String codeBarre);
}

/// Implémentation HTTPS de l'API publique v2 (cf. Docs/poc-scan-code-barres.md
/// §3.3). Best-effort : ne lève jamais — toute anomalie devient
/// [OffStatut.indisponible] ou [OffStatut.inconnu].
///
/// Sécurité / confidentialité :
///  - **HTTPS uniquement** (`Uri.https`), aucun repli en clair ;
///  - **seul le code-barres** (chiffres) est transmis, dans le chemin ;
///  - `User-Agent` **sans donnée personnelle** (politique Open Food Facts) ;
///  - délai borné ; aucun corps de réponse journalisé.
class HttpOpenFoodFactsService implements OpenFoodFactsService {
  /// Client injectable pour les tests ; en production un client éphémère est
  /// créé puis fermé à chaque appel.
  final http.Client? client;
  final Duration timeout;

  const HttpOpenFoodFactsService({
    this.client,
    this.timeout = const Duration(seconds: 4),
  });

  static const _hote = 'world.openfoodfacts.org';
  static const _champs =
      'product_name_fr,product_name,brands,categories_tags,quantity';
  static const _userAgent =
      'Miamo/1.0 (application mobile hors-ligne, sans compte)';

  @override
  Future<OffResultat> rechercher(String codeBarre) async {
    final chiffres = codeBarre.replaceAll(RegExp(r'\D'), '');
    if (chiffres.isEmpty) return const OffResultat(OffStatut.inconnu);

    final httpClient = client ?? http.Client();
    try {
      final uri = Uri.https(_hote, '/api/v2/product/$chiffres.json', {
        'fields': _champs,
      });
      final reponse = await httpClient
          .get(uri, headers: const {'User-Agent': _userAgent})
          .timeout(timeout);

      if (reponse.statusCode == 404) {
        return const OffResultat(OffStatut.inconnu);
      }
      if (reponse.statusCode != 200) {
        return const OffResultat(OffStatut.indisponible);
      }

      final corps = jsonDecode(reponse.body);
      if (corps is! Map<String, dynamic>) {
        return const OffResultat(OffStatut.indisponible);
      }
      if (corps['status'] != 1 || corps['product'] is! Map) {
        return const OffResultat(OffStatut.inconnu);
      }

      final p = (corps['product'] as Map).cast<String, dynamic>();
      final nomFr = (p['product_name_fr'] as String?)?.trim();
      final nom = (p['product_name'] as String?)?.trim();

      return OffResultat(
        OffStatut.trouve,
        OffProduit(
          code: chiffres,
          nom: (nomFr != null && nomFr.isNotEmpty)
              ? nomFr
              : (nom != null && nom.isNotEmpty ? nom : null),
          categoriesTags:
              (p['categories_tags'] as List?)?.whereType<String>().toList() ??
              const [],
          quantiteBrute: (p['quantity'] as String?)?.trim(),
        ),
      );
    } on TimeoutException {
      return const OffResultat(OffStatut.indisponible);
    } on http.ClientException {
      return const OffResultat(OffStatut.indisponible);
    } on FormatException {
      return const OffResultat(OffStatut.indisponible);
    } catch (_) {
      // Filet de sécurité : l'enrichissement ne doit jamais casser l'ajout.
      return const OffResultat(OffStatut.indisponible);
    } finally {
      if (client == null) httpClient.close();
    }
  }
}
