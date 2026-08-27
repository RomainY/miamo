import 'package:flutter/material.dart';

import 'constants.dart';
import '../theme/app_theme.dart';

/// Date/heure locale de déclenchement de la notification de péremption pour
/// [datePeremption] ([joursAvantNotification] jours avant, à
/// [heureNotification]h) — `null` si ce moment est déjà passé (pas de
/// notification à programmer). Logique pure (pas de fuseau horaire, pas de
/// plugin) pour rester testable indépendamment de `NotificationService`.
DateTime? dateDeclenchementNotification(
  DateTime datePeremption, {
  DateTime? maintenant,
}) {
  final jour = datePeremption.subtract(
    const Duration(days: joursAvantNotification),
  );
  final declenchement = DateTime(
    jour.year,
    jour.month,
    jour.day,
    heureNotification,
  );
  if (declenchement.isBefore(maintenant ?? DateTime.now())) return null;
  return declenchement;
}

/// Nombre de jours entre aujourd'hui et [date] (négatif si passé), en
/// ignorant l'heure. Base commune au badge d'urgence, au bandeau d'alerte et
/// à la planification des notifications.
int joursRestants(DateTime date) {
  final aujourdhui = DateTime.now();
  final today = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);
  final exp = DateTime(date.year, date.month, date.day);
  return exp.difference(today).inDays;
}

/// Urgence de péremption d'une instance frigo : libellé court + couleur,
/// pour le tri visuel demandé par cahier-des-charges.md §3.1 ("Tri
/// automatique par urgence de péremption, avec repère visuel").
class UrgencePeremption {
  final String label;
  final Color color;
  const UrgencePeremption(this.label, this.color);
}

/// `null` si le produit n'a pas de date de péremption (pas d'urgence à
/// afficher, cf. `datePeremption` optionnelle).
UrgencePeremption? urgencePeremption(DateTime? datePeremption) {
  if (datePeremption == null) return null;

  final diff = joursRestants(datePeremption);

  const perime = Color(0xFFC23B3B);
  const j3 = Color(0xFFB4711E);
  const j6 = Color(0xFF93831F);

  if (diff < 0) return const UrgencePeremption('Périmé', perime);
  if (diff == 0) return const UrgencePeremption("Aujourd'hui", perime);
  if (diff <= 3) return UrgencePeremption('J-$diff', j3);
  if (diff <= 7) return UrgencePeremption('J-$diff', j6);
  return UrgencePeremption(
    '${datePeremption.day.toString().padLeft(2, '0')}/'
    '${datePeremption.month.toString().padLeft(2, '0')}/'
    '${datePeremption.year}',
    AppColors.textMuted,
  );
}
