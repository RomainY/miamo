import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/reglage_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/constants.dart' as constantes;
import '../../../courses/presentation/providers/courses_providers.dart';
import '../../../frigo/presentation/widgets/reglage_recherche_en_ligne_tile.dart';

/// Écran Paramètres (`Docs/poc-liste-courses-auto.md` §11) : regroupe tous
/// les réglages applicatifs derrière le point d'entrée déjà existant
/// (Frigo → Catalogue → icône 🎛 « Réglages », `gerer_catalogue_page.dart`) —
/// pas de nouvel emplacement de navigation (§11.3).
class ReglagesSheet extends StatelessWidget {
  const ReglagesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          const _EnTete('Liste de courses'),
          const _SwitchReglage(
            titre: 'Suggestions selon mes repas planifiés',
            sousTitre:
                'Ingrédients manquants pour les repas planifiés, en tête de '
                'l\'écran Courses.',
            cle: kReglageSuggestionPlanificationActive,
          ),
          const _SwitchReglage(
            titre: 'Suggestions de rachat fréquent',
            sousTitre:
                'Produits souvent consommés/jetés et actuellement en '
                'rupture.',
            cle: kReglageSuggestionRuptureActive,
          ),
          _ChampNombreReglage(
            titre: 'Achats rapprochés avant suggestion',
            sousTitre: 'Nombre d\'occurrences consommé/jeté minimum.',
            cle: kReglageSeuilFrequenceRupture,
            defaut: constantes.seuilFrequenceRupture,
            min: 1,
            max: 100,
          ),
          _ChampNombreReglage(
            titre: 'Période de référence',
            sousTitre: 'Fenêtre glissante, en jours.',
            cle: kReglagePeriodeRuptureJours,
            defaut: constantes.periodeRuptureJours,
            min: 1,
            max: 100,
          ),
          const Divider(height: 24),
          const _EnTete('Péremption'),
          _ChampNombreReglage(
            titre: 'Alerte sur le frigo',
            sousTitre: 'Jours restants avant péremption, 0 = le jour même.',
            cle: kReglageSeuilAlerteBandeauJours,
            defaut: constantes.seuilAlerteBandeauJours,
            min: 0,
            max: 100,
          ),
          _ChampNombreReglage(
            titre: 'Notification envoyée',
            sousTitre: 'Jours avant péremption, 0 = le jour même.',
            cle: kReglageJoursAvantNotification,
            defaut: constantes.joursAvantNotification,
            min: 0,
            max: 100,
          ),
          _ChampNombreReglage(
            titre: 'Heure de la notification',
            sousTitre: '0-23h.',
            cle: kReglageHeureNotification,
            defaut: constantes.heureNotification,
            min: 0,
            max: 23,
          ),
          const Divider(height: 24),
          const _EnTete('Scan de produit'),
          const ReglageRechercheEnLigneTile(),
        ],
      ),
    );
  }
}

class _EnTete extends StatelessWidget {
  final String titre;
  const _EnTete(this.titre);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        titre,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Interrupteur générique, écrit au vol comme [ReglageRechercheEnLigneTile] —
/// absent en base = activé (défaut de tous les interrupteurs de ce POC).
class _SwitchReglage extends ConsumerWidget {
  final String titre;
  final String sousTitre;
  final String cle;

  const _SwitchReglage({
    required this.titre,
    required this.sousTitre,
    required this.cle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actif = switch (cle) {
      kReglageSuggestionPlanificationActive =>
        ref.watch(suggestionPlanificationActiveProvider).valueOrNull ?? true,
      kReglageSuggestionRuptureActive =>
        ref.watch(suggestionRuptureActiveProvider).valueOrNull ?? true,
      _ => true,
    };

    return SwitchListTile(
      title: Text(titre),
      subtitle: Text(sousTitre),
      value: actif,
      onChanged: (v) =>
          ref.read(reglageRepositoryProvider).ecrireBool(cle, v),
    );
  }
}

/// Champ numérique générique, borné [min]-[max] (§11.2 : `0` bloqué quand il
/// n'a pas de sens, autorisé sinon). Écriture au `onSubmitted`/perte de focus,
/// comme les autres réglages de l'écran.
class _ChampNombreReglage extends ConsumerStatefulWidget {
  final String titre;
  final String sousTitre;
  final String cle;
  final int defaut;
  final int min;
  final int max;

  const _ChampNombreReglage({
    required this.titre,
    required this.sousTitre,
    required this.cle,
    required this.defaut,
    required this.min,
    required this.max,
  });

  @override
  ConsumerState<_ChampNombreReglage> createState() =>
      _ChampNombreReglageState();
}

class _ChampNombreReglageState extends ConsumerState<_ChampNombreReglage> {
  final _controller = TextEditingController();
  bool _initialise = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valeur = ref
        .watch(
          reglageIntProvider((cle: widget.cle, defaut: widget.defaut)),
        )
        .valueOrNull;
    if (valeur != null && !_initialise) {
      _controller.text = valeur.toString();
      _initialise = true;
    }

    return ListTile(
      title: Text(widget.titre),
      subtitle: Text(widget.sousTitre),
      trailing: SizedBox(
        width: 56,
        child: TextField(
          controller: _controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: _valider,
          onTapOutside: (_) => _valider(_controller.text),
        ),
      ),
    );
  }

  void _valider(String texte) {
    final saisi = int.tryParse(texte);
    final borne = (saisi ?? widget.defaut).clamp(widget.min, widget.max);
    _controller.text = borne.toString();
    ref.read(reglageRepositoryProvider).ecrireInt(widget.cle, borne);
  }
}

/// Lecture réactive générique d'un réglage entier, clé/défaut en paramètre de
/// family (record — égalité structurelle, cf. `Docs/poc-liste-courses-auto.md`
/// §11.4).
final reglageIntProvider =
    StreamProvider.family<int, ({String cle, int defaut})>((ref, params) {
      return ref
          .watch(reglageRepositoryProvider)
          .observerInt(params.cle, defaut: params.defaut);
    });
