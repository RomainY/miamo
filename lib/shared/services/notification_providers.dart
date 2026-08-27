import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/frigo/presentation/providers/frigo_providers.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Maintient les notifications de péremption synchronisées avec le contenu
/// du frigo : se réexécute à chaque changement des instances en stock
/// (ajout, modification de date, consommé/jeté/supprimé). Doit être
/// "watché" une fois au niveau racine de l'app pour rester actif quel que
/// soit l'onglet affiché (cf. `app/app.dart`).
final notificationSyncProvider = Provider<void>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final instances = ref.watch(instancesEnStockGlobalProvider);
  instances.whenData(service.resynchroniser);
});
