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
    Reglages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur dédié aux tests (ex. `NativeDatabase.memory()`).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

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

  /// Migrations incrémentales, un `case` par palier `from` franchi.
  ///
  /// Les ajouts de colonne nullable (`ADD COLUMN`) ne touchent pas aux clés
  /// étrangères ni aux données : pas besoin de `PRAGMA foreign_keys = OFF`.
  /// Pour une reconstruction de table, désactiver les FK en tête (elles sont
  /// réactivées par `beforeOpen`).
  ///
  /// **v1 → v2** : ajout de `produit.code_barre` (nullable) + index UNIQUE
  /// `ux_produit_code_barre` (les NULL restent multiples).
  ///
  /// **v2 → v3** : table `reglage` (clé/valeur) — consentement à la recherche
  /// Open Food Facts.
  ///
  /// **v3 → v4** : injection des [categoriesDeBase] (`INSERT OR IGNORE`, ne
  /// touche pas aux catégories déjà créées par l'utilisateur) — aide au
  /// classement des produits, notamment depuis le scan.
  /// Cf. `Docs/poc-scan-code-barres.md` §4 & §5.4.
  Future<void> _onUpgrade(Migrator m, int from, int to) async {
    for (var palier = from; palier < to; palier++) {
      switch (palier) {
        case 1:
          await m.addColumn(produits, produits.codeBarre);
          await m.create(uxProduitCodeBarre);
        case 2:
          await m.createTable(reglages);
        case 3:
          for (final nom in categoriesDeBase) {
            await into(categories).insert(
              CategoriesCompanion.insert(nom: nom),
              mode: InsertMode.insertOrIgnore,
            );
          }
      }
    }
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
