import 'package:flutter/material.dart';

import '../../../../shared/utils/off_category_mapping.dart';

/// Puce « niveau de reconnaissance » affichée en tête du formulaire après un
/// scan (cf. Docs/poc-scan-code-barres.md §5.8). Purement informative : indique
/// si le produit est déjà connu, entièrement, partiellement ou pas reconnu, et
/// explique pourquoi certains champs ne sont pas pré-remplis.
class BarcodeRecognitionChip extends StatelessWidget {
  final ReconnaissanceProduit reconnaissance;

  const BarcodeRecognitionChip({super.key, required this.reconnaissance});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color couleur, IconData icone, String libelle) =
        switch (reconnaissance.niveau) {
          NiveauReconnaissance.catalogueLocal => (
            scheme.primary,
            Icons.inventory_2_outlined,
            'Déjà dans votre catalogue',
          ),
          NiveauReconnaissance.complet => (
            Colors.green.shade700,
            Icons.check_circle_outline,
            'Reconnu',
          ),
          NiveauReconnaissance.partiel => (
            Colors.orange.shade800,
            Icons.info_outline,
            'Partiellement reconnu',
          ),
          NiveauReconnaissance.aucun => (
            scheme.outline,
            Icons.help_outline,
            'Non reconnu',
          ),
        };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        border: Border.all(color: couleur.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 20, color: couleur),
              const SizedBox(width: 8),
              Text(
                libelle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: couleur,
                ),
              ),
            ],
          ),
          for (final raison in reconnaissance.raisons)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 28),
              child: Text(
                raison,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
