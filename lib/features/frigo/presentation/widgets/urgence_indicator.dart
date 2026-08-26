import 'package:flutter/material.dart';

import '../../../../shared/utils/date_utils.dart';

/// Badge de couleur + libellé (ex. "J-2", "Périmé") pour une date de
/// péremption. N'affiche rien si le produit n'a pas de date de péremption.
class UrgenceIndicator extends StatelessWidget {
  final DateTime? datePeremption;

  const UrgenceIndicator({super.key, required this.datePeremption});

  @override
  Widget build(BuildContext context) {
    final urgence = urgencePeremption(datePeremption);
    if (urgence == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: urgence.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        urgence.label,
        style: TextStyle(
          color: urgence.color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
