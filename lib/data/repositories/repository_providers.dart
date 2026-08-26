import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import 'article_course_repository.dart';
import 'categorie_repository.dart';
import 'plat_repository.dart';
import 'produit_frigo_repository.dart';
import 'produit_repository.dart';
import 'repas_planifie_repository.dart';
import 'unite_repository.dart';
import 'zone_repository.dart';

/// Providers transverses (documentation-technique.md §4 : la gestion du
/// catalogue et des instances est exposée via la couche repository plutôt
/// que rattachée à une feature unique).
final categorieRepositoryProvider = Provider<CategorieRepository>(
  (ref) => CategorieRepository(ref.watch(appDatabaseProvider)),
);

final zoneRepositoryProvider = Provider<ZoneRepository>(
  (ref) => ZoneRepository(ref.watch(appDatabaseProvider)),
);

final uniteRepositoryProvider = Provider<UniteRepository>(
  (ref) => UniteRepository(ref.watch(appDatabaseProvider)),
);

final produitRepositoryProvider = Provider<ProduitRepository>(
  (ref) => ProduitRepository(ref.watch(appDatabaseProvider)),
);

final produitFrigoRepositoryProvider = Provider<ProduitFrigoRepository>(
  (ref) => ProduitFrigoRepository(ref.watch(appDatabaseProvider)),
);

final platRepositoryProvider = Provider<PlatRepository>(
  (ref) => PlatRepository(ref.watch(appDatabaseProvider)),
);

final repasPlanifieRepositoryProvider = Provider<RepasPlanifieRepository>(
  (ref) => RepasPlanifieRepository(ref.watch(appDatabaseProvider)),
);

final articleCourseRepositoryProvider = Provider<ArticleCourseRepository>(
  (ref) => ArticleCourseRepository(ref.watch(appDatabaseProvider)),
);
