import 'package:flutter/material.dart';

import '../../../../data/repositories/repas_planifie_repository.dart';
import 'repas_list_tile.dart';

/// Liste de repas planifiés (vue jour ou vue "prochains repas").
class DayPlanningList extends StatelessWidget {
  final List<RepasPlanifieDetail> repas;
  final String messageVide;

  const DayPlanningList({
    super.key,
    required this.repas,
    this.messageVide = 'Aucun repas planifié.',
  });

  @override
  Widget build(BuildContext context) {
    if (repas.isEmpty) {
      return Center(child: Text(messageVide));
    }
    return ListView.separated(
      itemCount: repas.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) => RepasListTile(detail: repas[i]),
    );
  }
}
