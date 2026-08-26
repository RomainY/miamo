import 'package:flutter/material.dart';

/// Barre horizontale de filtres (catégories ou zones), avec une puce
/// "Toutes" pour désactiver le filtre (cahier-des-charges.md §3.1
/// "Filtrage par zone et/ou par catégorie").
class ChipsFilterBar extends StatelessWidget {
  final List<(int id, String label)> options;
  final int? selectedId;
  final ValueChanged<int?> onSelected;
  final String labelToutes;

  /// Couleur d'un point affiché devant chaque puce (ambiance "ludique" du
  /// quiz de style) — laissé `null` pour un filtre sans code couleur (ex.
  /// les zones, où la couleur n'a pas de sens).
  final Color Function(int id)? colorFor;

  const ChipsFilterBar({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.labelToutes = 'Toutes',
    this.colorFor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labelToutes),
              selected: selectedId == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: colorFor == null
                    ? null
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedId == option.$1
                              ? Colors.white
                              : colorFor!(option.$1),
                        ),
                      ),
                showCheckmark: false,
                label: Text(option.$2),
                selected: selectedId == option.$1,
                selectedColor: colorFor?.call(option.$1),
                labelStyle: selectedId == option.$1 && colorFor != null
                    ? const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      )
                    : null,
                onSelected: (_) => onSelected(option.$1),
              ),
            ),
        ],
      ),
    );
  }
}
