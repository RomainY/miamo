import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/frigo/presentation/providers/frigo_providers.dart';
import '../utils/constants.dart';
import 'notification_service.dart';
import 'reglages_peremption_providers.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Maintient les notifications de péremption synchronisées avec le contenu
/// du frigo : se réexécute à chaque changement des instances en stock
/// (ajout, modification de date, consommé/jeté/supprimé) ou des réglages
/// [joursAvantNotificationProvider]/[heureNotificationProvider] (écran
/// Paramètres, v1.2). Doit être "watché" une fois au niveau racine de l'app
/// pour rester actif quel que soit l'onglet affiché (cf. `app/app.dart`).
final notificationSyncProvider = Provider<void>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final instances = ref.watch(instancesEnStockGlobalProvider);
  final joursAvant =
      ref.watch(joursAvantNotificationProvider).valueOrNull ??
      joursAvantNotification;
  final heure =
      ref.watch(heureNotificationProvider).valueOrNull ?? heureNotification;
  final dureeConservationApresOuverture =
      ref.watch(dureeConservationApresOuvertureJoursProvider).valueOrNull ??
      dureeConservationApresOuvertureJours;
  instances.whenData(
    (liste) => service.resynchroniser(
      liste,
      joursAvant: joursAvant,
      heure: heure,
      dureeConservationApresOuverture: dureeConservationApresOuverture,
    ),
  );
});
