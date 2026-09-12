import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/reglage_repository.dart';
import '../../data/repositories/repository_providers.dart';
import '../utils/constants.dart' as constantes;

/// Réglages de péremption (`Docs/poc-liste-courses-auto.md` §11), réglables
/// depuis l'écran Paramètres — les constantes de `constants.dart` ne servent
/// plus que de valeur de repli tant que rien n'a été réglé.

final seuilAlerteBandeauJoursProvider = StreamProvider<int>((ref) {
  return ref
      .watch(reglageRepositoryProvider)
      .observerInt(
        kReglageSeuilAlerteBandeauJours,
        defaut: constantes.seuilAlerteBandeauJours,
      );
});

final joursAvantNotificationProvider = StreamProvider<int>((ref) {
  return ref
      .watch(reglageRepositoryProvider)
      .observerInt(
        kReglageJoursAvantNotification,
        defaut: constantes.joursAvantNotification,
      );
});

final heureNotificationProvider = StreamProvider<int>((ref) {
  return ref
      .watch(reglageRepositoryProvider)
      .observerInt(
        kReglageHeureNotification,
        defaut: constantes.heureNotification,
      );
});

final dureeConservationApresOuvertureJoursProvider = StreamProvider<int>((
  ref,
) {
  return ref
      .watch(reglageRepositoryProvider)
      .observerInt(
        kReglageDureeConservationApresOuvertureJours,
        defaut: constantes.dureeConservationApresOuvertureJours,
      );
});
