import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/produit_frigo_repository.dart';
import '../../../../data/repositories/repository_providers.dart';

/// Filtre "zone" actif sur l'écran Frigo (`null` = toutes les zones).
final frigoFiltreZoneProvider = StateProvider<int?>((ref) => null);

/// Filtre "catégorie" actif sur l'écran Frigo (`null` = toutes les
/// catégories).
final frigoFiltreCategorieProvider = StateProvider<int?>((ref) => null);

/// Instances en stock, triées par urgence, selon les filtres actifs
/// (cahier-des-charges.md §3.1 "Filtrage par zone et/ou par catégorie").
final instancesEnStockProvider = StreamProvider<List<InstanceFrigoDetail>>((
  ref,
) {
  final zoneId = ref.watch(frigoFiltreZoneProvider);
  final categorieId = ref.watch(frigoFiltreCategorieProvider);
  final repo = ref.watch(produitFrigoRepositoryProvider);
  return repo.watchEnStock(zoneId: zoneId, categorieId: categorieId);
});

/// Toutes les instances en stock, sans filtre — utilisé par le bandeau
/// d'alerte péremption et la synchronisation des notifications, qui doivent
/// rester indépendants du filtre actif sur l'écran Frigo.
final instancesEnStockGlobalProvider = StreamProvider<List<InstanceFrigoDetail>>((
  ref,
) {
  return ref.watch(produitFrigoRepositoryProvider).watchEnStock();
});

final categoriesProvider = StreamProvider<List<Categorie>>((ref) {
  return ref.watch(categorieRepositoryProvider).watchAll();
});

final zonesProvider = StreamProvider<List<Zone>>((ref) {
  return ref.watch(zoneRepositoryProvider).watchAll();
});

final unitesProvider = StreamProvider<List<Unite>>((ref) {
  return ref.watch(uniteRepositoryProvider).watchAll();
});

/// Autocomplétion des produits actifs, triée par usage récent, filtrable par
/// catégorie (cahier-des-charges.md §7.3).
final produitsActifsProvider = StreamProvider.family<List<Produit>, int?>((
  ref,
  categorieId,
) {
  return ref
      .watch(produitRepositoryProvider)
      .watchActifs(categorieId: categorieId);
});

/// Catalogue complet (actifs + archivés), pour l'écran de gestion du
/// catalogue (cahier-des-charges.md §7.3 "Consulter / filtrer le catalogue
/// par catégorie").
final produitsTousProvider = StreamProvider.family<List<Produit>, int?>((
  ref,
  categorieId,
) {
  return ref
      .watch(produitRepositoryProvider)
      .watchAll(categorieId: categorieId);
});
