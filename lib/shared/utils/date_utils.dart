import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'constants.dart';

/// Dates/heures locales de déclenchement des notifications de péremption
/// pour [datePeremption] : **une par jour**, de [joursAvant] jours avant la
/// péremption jusqu'au **lendemain** de la péremption inclus — pas une
/// notification isolée à J-[joursAvant] (règle corrigée le 07/09/2026 :
/// [joursAvant] fixe le début du rappel quotidien, pas son unique
/// occurrence). Exemple : péremption le 10, [joursAvant] = 2, [heure] = 9 →
/// rappels le 8, 9, 10 et 11 à 9h.
///
/// Seuls les déclenchements pas encore passés sont renvoyés (liste vide si
/// tous le sont déjà). Logique pure (pas de fuseau horaire, pas de plugin)
/// pour rester testable indépendamment de `NotificationService`.
/// [joursAvant]/[heure] sont réglables depuis l'écran Paramètres (v1.2,
/// `Docs/poc-liste-courses-auto.md` §11) ; les constantes de
/// `constants.dart` ne servent plus que de valeur par défaut.
List<DateTime> datesDeclenchementNotification(
  DateTime datePeremption, {
  DateTime? maintenant,
  int joursAvant = joursAvantNotification,
  int heure = heureNotification,
}) {
  final debut = datePeremption.subtract(Duration(days: joursAvant));
  final maintenantEffectif = maintenant ?? DateTime.now();
  // joursAvant jours avant, + le jour de péremption, + le lendemain.
  final nombreDeRappels = joursAvant + 2;

  return [
    for (var offset = 0; offset < nombreDeRappels; offset++)
      DateTime(debut.year, debut.month, debut.day + offset, heure),
  ].where((d) => !d.isBefore(maintenantEffectif)).toList();
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
