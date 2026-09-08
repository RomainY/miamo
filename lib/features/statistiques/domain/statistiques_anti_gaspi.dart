import '../../../data/database/app_database.dart';
import '../../../data/database/tables.dart';
import '../../../data/repositories/produit_frigo_repository.dart';

/// Bilan anti-gaspi d'un mois calendaire — comptage de lignes (pas de poids,
/// volontairement simple : cf. `Docs/poc-anti-gaspi-et-navigation.md` §A.1).
class BilanMensuel {
  /// Premier jour du mois (year/month portés, day/heure ignorés).
  final DateTime mois;
  final int nbConsomme;
  final int nbJete;

  const BilanMensuel({
    required this.mois,
    required this.nbConsomme,
    required this.nbJete,
  });

  int get total => nbConsomme + nbJete;

  /// `0` si le mois n'a aucune occurrence (pas de division par zéro) — un
  /// mois vide n'est pas un mois "parfait", juste sans donnée.
  double get tauxGaspillage => total == 0 ? 0 : nbJete / total;
}

/// Un produit et son nombre d'occurrences jetées sur la période — pour le
/// classement "Top gaspillage".
class ProduitGaspille {
  final int produitId;
  final String produitNom;
  final int nbJete;

  const ProduitGaspille({
    required this.produitId,
    required this.produitNom,
    required this.nbJete,
  });
}

/// Bilan global anti-gaspi sur la période couverte par [historique] (déjà
/// bornée par l'appelant, cf. `ProduitFrigoRepository.watchHistoriqueRecent`) :
/// un [BilanMensuel] par mois (les mois sans aucune occurrence n'apparaissent
/// pas), triés chronologiquement, et le classement [ProduitGaspille] des
/// produits les plus jetés sur l'ensemble de la période.
class BilanAntiGaspi {
  final List<BilanMensuel> parMois;
  final List<ProduitGaspille> topGaspillage;

  const BilanAntiGaspi({required this.parMois, required this.topGaspillage});

  int get nbConsommeTotal =>
      parMois.fold(0, (somme, m) => somme + m.nbConsomme);
  int get nbJeteTotal => parMois.fold(0, (somme, m) => somme + m.nbJete);

  double get tauxGaspillageGlobal {
    final total = nbConsommeTotal + nbJeteTotal;
    return total == 0 ? 0 : nbJeteTotal / total;
  }
}

DateTime _premierJourDuMois(DateTime d) => DateTime(d.year, d.month);

/// Agrège [historique] par mois calendaire (sur `dateStatut`) puis calcule le
/// "Top gaspillage" (produits les plus souvent jetés), résolus en nom via
/// [produitsParId]. Un produit disparu du catalogue (supprimé définitivement
/// entre-temps) est simplement omis du top — son historique n'existe alors
/// déjà plus dans [historique] (suppression en cascade, comportement assumé
/// depuis le MVP).
BilanAntiGaspi calculerBilanAntiGaspi({
  required List<HistoriqueStatutProduit> historique,
  required Map<int, Produit> produitsParId,
}) {
  final parMois = <DateTime, ({int consomme, int jete})>{};
  final jetesParProduit = <int, int>{};

  for (final h in historique) {
    final mois = _premierJourDuMois(h.dateStatut);
    final courant = parMois[mois] ?? (consomme: 0, jete: 0);
    parMois[mois] = h.statut == StatutProduitFrigo.jete
        ? (consomme: courant.consomme, jete: courant.jete + 1)
        : (consomme: courant.consomme + 1, jete: courant.jete);

    if (h.statut == StatutProduitFrigo.jete) {
      jetesParProduit.update(
        h.produitId,
        (v) => v + 1,
        ifAbsent: () => 1,
      );
    }
  }

  final bilans =
      parMois.entries
          .map(
            (e) => BilanMensuel(
              mois: e.key,
              nbConsomme: e.value.consomme,
              nbJete: e.value.jete,
            ),
          )
          .toList()
        ..sort((a, b) => a.mois.compareTo(b.mois));

  final top =
      jetesParProduit.entries
          .where((e) => produitsParId.containsKey(e.key))
          .map(
            (e) => ProduitGaspille(
              produitId: e.key,
              produitNom: produitsParId[e.key]!.nom,
              nbJete: e.value,
            ),
          )
          .toList()
        ..sort((a, b) => b.nbJete.compareTo(a.nbJete));

  return BilanAntiGaspi(parMois: bilans, topGaspillage: top);
}
