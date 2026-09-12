import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/reglages_peremption_providers.dart';
import '../../../../shared/utils/constants.dart' as constantes;
import '../../../../shared/utils/date_utils.dart';

/// Badge "Ouvert depuis Xj" pour une instance marquée entamée
/// (`dateOuverture` non nulle), coloré selon la proximité de la limite de
/// conservation réglée (écran Paramètres > "Une fois ouvert"). N'affiche
/// rien tant que le produit n'a pas été marqué entamé.
class OuvertureIndicator extends ConsumerWidget {
  final DateTime? dateOuverture;

  const OuvertureIndicator({super.key, required this.dateOuverture});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = dateOuverture;
    if (date == null) return const SizedBox.shrink();

    final duree =
        ref.watch(dureeConservationApresOuvertureJoursProvider).valueOrNull ??
        constantes.dureeConservationApresOuvertureJours;
    final limite = date.add(Duration(days: duree));
    final joursEcoules = -joursRestants(date);
    final joursAvantLimite = joursRestants(limite);

    const depasse = Color(0xFFC23B3B);
    const proche = Color(0xFFB4711E);
    const ok = Color(0xFF3B7A57);
    final couleur = joursAvantLimite < 0
        ? depasse
        : joursAvantLimite <= 1
        ? proche
        : ok;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timelapse, size: 14, color: couleur),
          const SizedBox(width: 4),
          Text(
            'Ouvert depuis ${joursEcoules}j',
            style: TextStyle(
              color: couleur,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
