import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/tables.dart';
import '../../../../data/repositories/repas_planifie_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/widgets/action_feedback.dart';
import '../providers/planification_providers.dart';
import 'disponibilite_badge.dart';

/// Une ligne de repas planifié : titre (plat ou produit), portions, statut,
/// actions rapides "Marquer fait" / "Annuler" (cahier-des-charges.md §7.5).
/// Pour un repas planifié dont un ingrédient manque ou est insuffisant au
/// regard du stock, une pastille "Stock incomplet" / "Ingrédient manquant"
/// est affichée sous le sous-titre.
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

    final dispo = repas.statut == StatutRepas.planifie
        ? ref.watch(disponibilitesRepasProvider)[repas.id]
        : null;
    final afficheBadge = dispo != null && !dispo.ok;

    return ListTile(
      isThreeLine: afficheBadge,
      title: Text(detail.titre),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sousTitre),
          if (afficheBadge)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DisponibiliteBadge(dispo: dispo),
              ),
            ),
        ],
      ),
      trailing: switch (repas.statut) {
        StatutRepas.planifie => PopupMenuButton<String>(
          onSelected: (action) async {
            final repo = ref.read(repasPlanifieRepositoryProvider);
            switch (action) {
              case 'fait':
                await lancerAction(
                  context,
                  () => repo.marquerFait(repas.id),
                  messageErreur: 'Impossible de marquer ce repas comme fait.',
                );
              case 'annule':
                await lancerAction(context, () => repo.annuler(repas.id));
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
