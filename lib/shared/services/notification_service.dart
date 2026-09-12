import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/repositories/produit_frigo_repository.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';

/// Notifications locales de péremption imminente (cahier-des-charges.md §4),
/// 100% offline — aucune dépendance réseau, juste le planificateur
/// d'alarmes du système.
///
/// ⚠️ Règle non spécifiée par le cahier des charges, corrigée le 07/09/2026 :
/// **un rappel par jour**, de [joursAvant] jours avant la date de péremption
/// jusqu'au lendemain de la péremption inclus, à [heure]h (pas une
/// notification isolée à J-[joursAvant]) — cf. `date_utils.dart`
/// `datesDeclenchementNotification`. Réglable depuis l'écran Paramètres
/// (v1.2), défauts dans `shared/utils/constants.dart`.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialise = false;

  /// Canal unique de l'app, partagé par les vraies notifications et les
  /// notifications de test (§ outils de debug ci-dessous).
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'peremption',
      'Péremption',
      channelDescription: 'Alerte de péremption imminente',
    ),
  );

  /// Identifiants réservés aux notifications de test, hors de la plage
  /// utilisée par [_planifierPourInstance]/[_planifierOuverturePourInstance]
  /// (`instanceId * 10000 + offset` pour la péremption, `+ 5000 + offset`
  /// pour la limite après ouverture — `instanceId` positif et `offset`
  /// toujours borné par la fenêtre de rappel, jamais assez grand pour
  /// atteindre la plage voisine ni les identifiants de test).
  static const _idTestImmediat = 900000001;
  static const _idTestProgramme = 900000002;

  Future<void> _assurerInitialisation() async {
    if (_initialise) return;

    tz_data.initializeTimeZones();
    try {
      final fuseau = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(fuseau.identifier));
    } catch (_) {
      // Fuseau non détecté (ex. plateforme de test) : reste sur UTC par
      // défaut plutôt que d'échouer toute la synchronisation.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialise = true;
  }

  /// Reprogramme l'intégralité des notifications à partir de la liste
  /// actuelle des instances en stock. Approche "tout annuler puis
  /// reprogrammer" plutôt qu'un diff incrémental : plus simple, auto-
  /// réparatrice, et sans coût perceptible vu le volume attendu (dizaines
  /// d'instances, pas plus).
  ///
  /// Échoue silencieusement (trace `dart:developer`, non émise en release) si
  /// le plugin de notifications n'est pas disponible sur la plateforme courante
  /// (ex. tests, desktop) : une notification manquée ne doit jamais faire
  /// planter l'app.
  Future<void> resynchroniser(
    List<InstanceFrigoDetail> instances, {
    int joursAvant = joursAvantNotification,
    int heure = heureNotification,
    int dureeConservationApresOuverture = dureeConservationApresOuvertureJours,
  }) async {
    try {
      await _assurerInitialisation();
      await _plugin.cancelAll();

      for (final detail in instances) {
        final datePeremption = detail.instance.datePeremption;
        if (datePeremption != null) {
          await _planifierPourInstance(
            instanceId: detail.instance.id,
            produitNom: detail.produit.nom,
            datePeremption: datePeremption,
            joursAvant: joursAvant,
            heure: heure,
          );
        }

        final dateOuverture = detail.instance.dateOuverture;
        if (dateOuverture != null) {
          await _planifierOuverturePourInstance(
            instanceId: detail.instance.id,
            produitNom: detail.produit.nom,
            dateLimite: dateOuverture.add(
              Duration(days: dureeConservationApresOuverture),
            ),
            joursAvant: joursAvant,
            heure: heure,
          );
        }
      }
    } catch (e, stack) {
      developer.log(
        'Resynchronisation des notifications échouée',
        name: 'miamo.notifications',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Programme un rappel par jour (cf. note de tête de fichier) : un
  /// identifiant distinct par jour de la fenêtre (`instanceId * 10000 +
  /// offset`) puisqu'une seule instance peut désormais porter plusieurs
  /// notifications programmées simultanément.
  Future<void> _planifierPourInstance({
    required int instanceId,
    required String produitNom,
    required DateTime datePeremption,
    required int joursAvant,
    required int heure,
  }) async {
    final declenchements = _datesDeclenchement(
      datePeremption,
      joursAvant: joursAvant,
      heure: heure,
    );

    for (var offset = 0; offset < declenchements.length; offset++) {
      await _plugin.zonedSchedule(
        id: instanceId * 10000 + offset,
        title: 'Ça périme bientôt',
        body: '$produitNom périme le ${_formatDate(datePeremption)}.',
        scheduledDate: declenchements[offset],
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Même principe que [_planifierPourInstance], pour la limite de
  /// consommation d'un produit entamé (`dateLimite` = date d'ouverture +
  /// durée de conservation réglée). Plage d'identifiants distincte
  /// (`+ 5000`) pour ne jamais entrer en conflit avec les rappels de
  /// péremption d'une même instance.
  Future<void> _planifierOuverturePourInstance({
    required int instanceId,
    required String produitNom,
    required DateTime dateLimite,
    required int joursAvant,
    required int heure,
  }) async {
    final declenchements = _datesDeclenchement(
      dateLimite,
      joursAvant: joursAvant,
      heure: heure,
    );

    for (var offset = 0; offset < declenchements.length; offset++) {
      await _plugin.zonedSchedule(
        id: instanceId * 10000 + 5000 + offset,
        title: 'Produit entamé à consommer',
        body: '$produitNom est ouvert depuis un moment — à consommer avant '
            'le ${_formatDate(dateLimite)}.',
        scheduledDate: declenchements[offset],
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  List<tz.TZDateTime> _datesDeclenchement(
    DateTime datePeremption, {
    required int joursAvant,
    required int heure,
  }) {
    final locales = datesDeclenchementNotification(
      datePeremption,
      joursAvant: joursAvant,
      heure: heure,
    );
    return [
      for (final l in locales)
        tz.TZDateTime(tz.local, l.year, l.month, l.day, l.hour),
    ];
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  // ─── Outils de debug (écran Paramètres, visibles en debug uniquement —
  // cf. `ReglagesSheet`) ─────────────────────────────────────────────────
  //
  // Servent à vérifier le rendu/canal/pipeline de planification sans
  // attendre une vraie échéance de péremption (demande du 07/09/2026,
  // suite au changement de règle "une notification -> un rappel quotidien").

  /// Envoie immédiatement une notification de test (rendu, son, canal).
  Future<void> envoyerNotificationTest() async {
    await _assurerInitialisation();
    await _plugin.show(
      id: _idTestImmediat,
      title: 'Notification de test',
      body: 'Envoyée manuellement depuis Paramètres — aucune donnée réelle.',
      notificationDetails: _details,
    );
  }

  /// Programme une notification de test dans [delai], pour vérifier le
  /// pipeline réel de planification (fuseau horaire, réveil de l'app par le
  /// système). Écrase toute notification de test programmée précédente.
  Future<void> programmerNotificationTest(Duration delai) async {
    await _assurerInitialisation();
    final quand = tz.TZDateTime.now(tz.local).add(delai);
    await _plugin.zonedSchedule(
      id: _idTestProgramme,
      title: 'Notification de test (programmée)',
      body: 'Programmée pour dans ${delai.inSeconds} s.',
      scheduledDate: quand,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Notifications actuellement en attente (réelles + tests confondus), pour
  /// inspection — la plateforme ne renvoie ni la date ni l'heure programmée,
  /// seulement id/titre/corps.
  Future<List<PendingNotificationRequest>> notificationsProgrammees() async {
    await _assurerInitialisation();
    return _plugin.pendingNotificationRequests();
  }
}
