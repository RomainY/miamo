import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/reglage_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/services/notification_providers.dart';
import '../../../../shared/services/reglages_peremption_providers.dart';
import '../../../../shared/utils/constants.dart' as constantes;
import '../../../../shared/utils/date_utils.dart';
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
          if (kDebugMode) ...[
            const Divider(height: 24),
            const _EnTete('Debug — notifications (visible en debug uniquement)'),
            const _DebugNotificationsSection(),
          ],
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

/// Outils de test des notifications de péremption — **visibles en debug
/// uniquement** (`kDebugMode`, jamais en release). Ajoutés le 07/09/2026
/// suite à la correction de règle : une notification = un rappel quotidien
/// de `joursAvant` jours avant la péremption jusqu'au lendemain inclus, plus
/// difficile à vérifier "en vrai" qu'une notification isolée.
class _DebugNotificationsSection extends ConsumerStatefulWidget {
  const _DebugNotificationsSection();

  @override
  ConsumerState<_DebugNotificationsSection> createState() =>
      _DebugNotificationsSectionState();
}

class _DebugNotificationsSectionState
    extends ConsumerState<_DebugNotificationsSection> {
  DateTime _peremptionApercu = DateTime.now().add(const Duration(days: 3));

  @override
  Widget build(BuildContext context) {
    final joursAvant =
        ref.watch(joursAvantNotificationProvider).valueOrNull ??
        constantes.joursAvantNotification;
    final heure =
        ref.watch(heureNotificationProvider).valueOrNull ??
        constantes.heureNotification;
    // maintenant très ancien : l'aperçu montre tout le calendrier de rappels,
    // y compris ceux qui seraient déjà passés pour de vrai.
    final apercu = datesDeclenchementNotification(
      _peremptionApercu,
      maintenant: DateTime(2000),
      joursAvant: joursAvant,
      heure: heure,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: const Text('Envoyer une notification maintenant'),
          subtitle: const Text('Vérifie le rendu, le son, le canal.'),
          trailing: FilledButton(
            onPressed: () => _executer(
              () => ref
                  .read(notificationServiceProvider)
                  .envoyerNotificationTest(),
              'Notification envoyée.',
            ),
            child: const Text('Envoyer'),
          ),
        ),
        ListTile(
          title: const Text('Programmer dans 10 secondes'),
          subtitle: const Text(
            'Vérifie le pipeline réel de planification (fuseau, réveil).',
          ),
          trailing: FilledButton(
            onPressed: () => _executer(
              () => ref
                  .read(notificationServiceProvider)
                  .programmerNotificationTest(const Duration(seconds: 10)),
              'Programmée pour dans 10 s.',
            ),
            child: const Text('Programmer'),
          ),
        ),
        ListTile(
          title: const Text('Notifications actuellement programmées'),
          subtitle: const Text('Réelles + tests confondus.'),
          trailing: OutlinedButton(
            onPressed: _voirProgrammees,
            child: const Text('Voir'),
          ),
        ),
        const Divider(height: 16),
        ListTile(
          title: const Text('Aperçu du calendrier de rappels'),
          subtitle: Text(
            'Pour une péremption fictive le ${_fmtDate(_peremptionApercu)}, '
            'avec les réglages actuels (J-$joursAvant, ${heure}h).',
          ),
          trailing: TextButton(
            onPressed: _choisirDateApercu,
            child: const Text('Changer la date'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: apercu.isEmpty
              ? const Text('Aucun rappel (période entièrement passée).')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final d in apercu) Chip(label: Text(_fmtDateHeure(d))),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _executer(
    Future<void> Function() action,
    String messageSucces,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(messageSucces)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Échec : $e')));
    }
  }

  Future<void> _voirProgrammees() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final liste = await ref
          .read(notificationServiceProvider)
          .notificationsProgrammees();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${liste.length} notification(s) programmée(s)'),
          content: SizedBox(
            width: double.maxFinite,
            child: liste.isEmpty
                ? const Text('Aucune.')
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final n in liste)
                        ListTile(
                          dense: true,
                          title: Text(n.title ?? '(sans titre)'),
                          subtitle: Text('#${n.id} · ${n.body ?? ''}'),
                        ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Échec : $e')));
    }
  }

  Future<void> _choisirDateApercu() async {
    final choisie = await showDatePicker(
      context: context,
      initialDate: _peremptionApercu,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (choisie != null) setState(() => _peremptionApercu = choisie);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  String _fmtDateHeure(DateTime d) => '${_fmtDate(d)} ${d.hour}h';
}
