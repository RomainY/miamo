import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/tables.dart';
import '../../../../data/repositories/repas_planifie_repository.dart';
import '../../../../data/repositories/repository_providers.dart';

/// Une ligne de repas planifié : titre (plat ou produit), portions, statut,
/// actions rapides "Marquer fait" / "Annuler" (cahier-des-charges.md §7.5).
class RepasListTile extends ConsumerWidget {
  final RepasPlanifieDetail detail;
  const RepasListTile({super.key, required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repas = detail.repas;
    final sousTitre = [
      '${repas.portions} portion(s)',
      if (detail.plat?.tempsPrepa != null) '${detail.plat!.tempsPrepa} min',
      '${repas.date.day.toString().padLeft(2, '0')}/'
          '${repas.date.month.toString().padLeft(2, '0')}/'
          '${repas.date.year}',
    ].join(' · ');

    return ListTile(
      title: Text(detail.titre),
      subtitle: Text(sousTitre),
      trailing: switch (repas.statut) {
        StatutRepas.planifie => PopupMenuButton<String>(
          onSelected: (action) {
            final repo = ref.read(repasPlanifieRepositoryProvider);
            switch (action) {
              case 'fait':
                repo.marquerFait(repas.id);
              case 'annule':
                repo.annuler(repas.id);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'fait', child: Text('Marquer fait')),
            PopupMenuItem(value: 'annule', child: Text('Annuler')),
          ],
        ),
        StatutRepas.fait => const Chip(label: Text('Fait')),
        StatutRepas.annule => const Chip(label: Text('Annulé')),
      },
    );
  }
}
