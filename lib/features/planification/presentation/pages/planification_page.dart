import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/repas_planifie_repository.dart';
import '../providers/planification_providers.dart';
import '../widgets/calendar_view.dart';
import '../widgets/day_planning_list.dart';
import 'planifier_repas_sheet.dart';
import 'plats_page.dart';

DateTime _sansHeure(DateTime d) => DateTime(d.year, d.month, d.day);

/// Écran principal du module Planification (cahier-des-charges.md §3.2) :
/// vue calendrier et vue liste des prochains repas, interchangeables.
class PlanificationPage extends ConsumerStatefulWidget {
  const PlanificationPage({super.key});

  @override
  ConsumerState<PlanificationPage> createState() => _PlanificationPageState();
}

class _PlanificationPageState extends ConsumerState<PlanificationPage> {
  DateTime _moisAffiche = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final vue = ref.watch(vuePlanificationProvider);
    final dateSelectionnee = ref.watch(dateSelectionneeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Mes plats',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PlatsPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SegmentedButton<VuePlanification>(
            segments: const [
              ButtonSegment(
                value: VuePlanification.calendrier,
                label: Text('Calendrier'),
                icon: Icon(Icons.calendar_month),
              ),
              ButtonSegment(
                value: VuePlanification.liste,
                label: Text('Liste'),
                icon: Icon(Icons.list),
              ),
            ],
            selected: {vue},
            onSelectionChanged: (s) =>
                ref.read(vuePlanificationProvider.notifier).state = s.first,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: vue == VuePlanification.calendrier
                ? _buildVueCalendrier(dateSelectionnee)
                : _buildVueListe(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showPlanifierRepasSheet(context, dateInitiale: dateSelectionnee),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVueCalendrier(DateTime dateSelectionnee) {
    final repasMois = ref.watch(
      repasMoisProvider(DateTime(_moisAffiche.year, _moisAffiche.month)),
    );

    return repasMois.when(
      data: (liste) {
        final parJour = <DateTime, int>{};
        for (final d in liste) {
          final jour = _sansHeure(d.repas.date);
          parJour[jour] = (parJour[jour] ?? 0) + 1;
        }
        final repasJourSelectionne = liste
            .where(
              (d) => _sansHeure(d.repas.date) == _sansHeure(dateSelectionnee),
            )
            .toList();

        return Column(
          children: [
            CalendarView(
              focusedDay: _moisAffiche,
              selectedDay: dateSelectionnee,
              nombreRepasParJour: parJour,
              onDaySelected: (day) {
                ref.read(dateSelectionneeProvider.notifier).state = day;
              },
              onPageChanged: (focused) =>
                  setState(() => _moisAffiche = focused),
            ),
            const Divider(height: 16),
            Expanded(
              child: DayPlanningList(
                repas: repasJourSelectionne,
                messageVide: 'Aucun repas planifié ce jour-là.',
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
    );
  }

  Widget _buildVueListe() {
    final AsyncValue<List<RepasPlanifieDetail>> repas = ref.watch(
      repasProchainsProvider,
    );
    return repas.when(
      data: (liste) => DayPlanningList(
        repas: liste,
        messageVide: 'Aucun repas planifié à venir.',
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
    );
  }
}
