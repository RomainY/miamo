import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'seeders.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Base SQLite locale unique de l'application (fichier `app_frigo`, via
/// `drift_flutter`). Aucune synchronisation distante.
///
/// **Faire évoluer le schéma** (ajout de colonne, table, contrainte…) :
/// 1. Modifier les tables dans `tables.dart`.
/// 2. Incrémenter [schemaVersion].
/// 3. Ajouter un `case` dans [_onUpgrade] pour l'intervalle `from -> to`
///    (`ALTER TABLE`, `m.createTable(...)`, back-fill…).
/// 4. Régénérer : `dart run build_runner build --delete-conflicting-outputs`.
/// 5. Couvrir la migration par un test (ouvrir une base v(N-1), migrer,
///    vérifier les données).
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
    onUpgrade: _onUpgrade,
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Aucune migration à ce jour (schéma en version 1). Au premier changement
  /// de schéma, désactiver les clés étrangères en tête (`PRAGMA foreign_keys
  /// = OFF`, réactivées par `beforeOpen`), puis traiter chaque intervalle :
  ///
  /// ```dart
  /// switch (from) {
  ///   case 1:
  ///     await m.addColumn(produits, produits.nouveauChamp);
  ///     continue v2;
  ///   v2:
  ///   case 2:
  ///     // ...
  /// }
  /// ```
  Future<void> _onUpgrade(Migrator m, int from, int to) async {
    throw UnsupportedError(
      'Migration de la base v$from -> v$to non implémentée '
      '(voir AppDatabase._onUpgrade).',
    );
  }

  /// Ouvre la base fichier dans le répertoire applicatif (résolu par
  /// `path_provider`).
  ///
  /// Base **non chiffrée** — décision d'audit actée (SEC-01, cf.
  /// AUDIT_REPORT.md) : les données stockées (frigo, plats, planning) ne
  /// contiennent ni secret ni donnée personnelle sensible, et l'app n'a pas de
  /// compte. Le surcoût d'une gestion de clé (`flutter_secure_storage` +
  /// SQLCipher) n'est pas justifié. À réévaluer si des données sensibles
  /// venaient à être stockées.
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'app_frigo');
  }
}
