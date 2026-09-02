import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'open_food_facts_service.dart';

/// Recherche de produit par code-barres via Open Food Facts. Surchargé en test
/// par un faux (aucun appel réseau).
final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>(
  (ref) => const HttpOpenFoodFactsService(),
);
