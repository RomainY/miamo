import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'seeders.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Zones,
    Unites,
    Produits,
    ProduitsFrigo,
    Plats,
    PlatIngredients,
    RepasPlanifies,
    ArticlesCourse,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur dédié aux tests (ex. `NativeDatabase.memory()`).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await seedInitialData(this);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'app_frigo');
  }
}
