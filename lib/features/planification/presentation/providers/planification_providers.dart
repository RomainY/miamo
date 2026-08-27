import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/repas_planifie_repository.dart';
import '../../../../data/repositories/repository_providers.dart';

/// Jour actuellement sélectionné dans la vue calendrier.
final dateSelectionneeProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

/// Vue active : calendrier ou liste des prochains repas
/// (cahier-des-charges.md §3.2 "deux vues combinées et interchangeables").
enum VuePlanification { calendrier, liste }

final vuePlanificationProvider = StateProvider<VuePlanification>(
  (ref) => VuePlanification.calendrier,
);

final platsProvider = StreamProvider<List<Plat>>((ref) {
  return ref.watch(platRepositoryProvider).watchAll();
});

/// Repas planifiés du mois affiché par le calendrier (bornes larges pour
/// couvrir les jours des mois voisins visibles dans la grille).
final repasMoisProvider =
    StreamProvider.family<List<RepasPlanifieDetail>, DateTime>((ref, mois) {
      final debut = DateTime(mois.year, mois.month - 1, 21);
      final fin = DateTime(mois.year, mois.month + 2, 10);
      return ref
          .watch(repasPlanifieRepositoryProvider)
          .watchByDateRangeDetail(debut, fin);
    });

final repasProchainsProvider = StreamProvider<List<RepasPlanifieDetail>>((ref) {
  return ref.watch(repasPlanifieRepositoryProvider).watchProchainsDetail();
});
