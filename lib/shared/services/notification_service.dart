import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/repositories/produit_frigo_repository.dart';
import '../utils/date_utils.dart';

/// Notifications locales de péremption imminente (cahier-des-charges.md §4),
/// 100% offline — aucune dépendance réseau, juste le planificateur
/// d'alarmes du système.
///
/// ⚠️ Règle non spécifiée par le cahier des charges : une notification est
/// programmée [joursAvantNotification] jours avant la date de péremption, à
/// [heureNotification]h. À ajuster si besoin (cf. `shared/utils/constants.dart`).
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialise = false;

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
  Future<void> resynchroniser(List<InstanceFrigoDetail> instances) async {
    try {
      await _assurerInitialisation();
      await _plugin.cancelAll();

      for (final detail in instances) {
        final datePeremption = detail.instance.datePeremption;
        if (datePeremption == null) continue;
        await _planifierPourInstance(
          instanceId: detail.instance.id,
          produitNom: detail.produit.nom,
          datePeremption: datePeremption,
        );
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

  Future<void> _planifierPourInstance({
    required int instanceId,
    required String produitNom,
    required DateTime datePeremption,
  }) async {
    final declenchement = _dateDeclenchement(datePeremption);
    if (declenchement == null) return;

    await _plugin.zonedSchedule(
      id: instanceId,
      title: 'Ça périme bientôt',
      body: '$produitNom périme le ${_formatDate(datePeremption)}.',
      scheduledDate: declenchement,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'peremption',
          'Péremption',
          channelDescription: 'Alerte de péremption imminente',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  tz.TZDateTime? _dateDeclenchement(DateTime datePeremption) {
    final locale = dateDeclenchementNotification(datePeremption);
    if (locale == null) return null;
    return tz.TZDateTime(
      tz.local,
      locale.year,
      locale.month,
      locale.day,
      locale.hour,
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}
