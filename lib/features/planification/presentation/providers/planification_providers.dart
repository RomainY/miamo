import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/repas_planifie_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../frigo/presentation/providers/frigo_providers.dart';
import '../../domain/disponibilite_ingredients.dart';

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

// ─── Disponibilité des ingrédients des repas planifiés ────────────────────

/// Tous les repas au statut `planifie` (toutes dates), base de l'allocation
/// cumulée du stock.
final repasPlanifiesDetailProvider = StreamProvider<List<RepasPlanifieDetail>>((
  ref,
) {
  return ref.watch(repasPlanifieRepositoryProvider).watchPlanifiesDetail();
});

/// Ingrédients de tous les plats, regroupés par `platId`.
final ingredientsParPlatProvider =
    StreamProvider<Map<int, List<PlatIngredient>>>((ref) {
      return ref.watch(platRepositoryProvider).watchTousIngredients().map((
        lignes,
      ) {
        final parPlat = <int, List<PlatIngredient>>{};
        for (final ing in lignes) {
          (parPlat[ing.platId] ??= []).add(ing);
        }
        return parPlat;
      });
    });

/// Catalogue produits indexé par id (nom, unité par défaut, type de grandeur).
final produitsParIdProvider = StreamProvider<Map<int, Produit>>((ref) {
  return ref.watch(produitRepositoryProvider).watchAll().map(
    (liste) => {for (final p in liste) p.id: p},
  );
});

/// Bilan de disponibilité par repas planifié (`repasId` -> [DisponibiliteRepas]).
/// Recalculé dès qu'une des entrées change : stock frigo, repas planifiés,
/// ingrédients des plats, catalogue produits, unités.
final disponibilitesRepasProvider = Provider<Map<int, DisponibiliteRepas>>((
  ref,
) {
  final repas =
      ref.watch(repasPlanifiesDetailProvider).valueOrNull ??
      const <RepasPlanifieDetail>[];
  final stock = ref.watch(instancesEnStockGlobalProvider).valueOrNull ?? const [];
  final ingredients =
      ref.watch(ingredientsParPlatProvider).valueOrNull ?? const {};
  final produits = ref.watch(produitsParIdProvider).valueOrNull ?? const {};
  final unites = {
    for (final u in ref.watch(unitesProvider).valueOrNull ?? const <Unite>[])
      u.id: u,
  };

  return calculerDisponibilites(
    repasPlanifies: repas,
    stock: stock,
    ingredientsParPlat: ingredients,
    unitesParId: unites,
    produitsParId: produits,
  );
});

/// Données brutes partagées par les calculs de disponibilité, sous une forme
/// directement exploitable (`null` tant que les streams n'ont pas émis).
typedef _EntreesDispo = ({
  Map<int, List<PlatIngredient>> ingredientsParPlat,
  Map<int, Produit> produitsParId,
  Map<int, Unite> unitesParId,
});

final _entreesDispoProvider = Provider<_EntreesDispo>((ref) {
  return (
    ingredientsParPlat:
        ref.watch(ingredientsParPlatProvider).valueOrNull ?? const {},
    produitsParId: ref.watch(produitsParIdProvider).valueOrNull ?? const {},
    unitesParId: {
      for (final u in ref.watch(unitesProvider).valueOrNull ?? const <Unite>[])
        u.id: u,
    },
  );
});

/// Pool de stock résiduel une fois tous les repas planifiés existants alloués :
/// base pour l'aperçu de disponibilité d'un repas candidat dans le formulaire
/// « Planifier un repas ».
final poolResiduelProvider = Provider<PoolStock>((ref) {
  final repas =
      ref.watch(repasPlanifiesDetailProvider).valueOrNull ??
      const <RepasPlanifieDetail>[];
  final stock = ref.watch(instancesEnStockGlobalProvider).valueOrNull ?? const [];
  final entrees = ref.watch(_entreesDispoProvider);

  final pool = construirePool(stock);
  for (final r in ordonnerPourAllocation(repas)) {
    evaluerRepas(
      pool: pool,
      repas: r,
      ingredientsParPlat: entrees.ingredientsParPlat,
      unitesParId: entrees.unitesParId,
      produitsParId: entrees.produitsParId,
    );
  }
  return pool;
});
