import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

/// Seed exécuté une seule fois, à la création de la base (cf.
/// documentation-technique.md §2) :
/// - catégorie par défaut "Non classé" (réaffectation, non supprimable)
/// - zone racine "Frigo" (is_root = true, réaffectation, non supprimable)
/// - unités de base pour chaque type_grandeur
Future<void> seedInitialData(AppDatabase db) async {
  await db.into(db.categories).insert(
        const CategoriesCompanion(
          nom: Value('Non classé'),
          icone: Value('category'),
          estParDefaut: Value(true),
        ),
      );

  await db.into(db.zones).insert(
        const ZonesCompanion(
          nom: Value('Frigo'),
          icone: Value('kitchen'),
          isRoot: Value(true),
        ),
      );

  await db.batch((batch) {
    batch.insertAll(db.unites, const [
      UnitesCompanion(
        nom: Value('gramme'),
        typeGrandeur: Value(TypeGrandeur.masse),
        facteurVersBase: Value(1),
      ),
      UnitesCompanion(
        nom: Value('kilogramme'),
        typeGrandeur: Value(TypeGrandeur.masse),
        facteurVersBase: Value(1000),
      ),
      UnitesCompanion(
        nom: Value('millilitre'),
        typeGrandeur: Value(TypeGrandeur.volume),
        facteurVersBase: Value(1),
      ),
      UnitesCompanion(
        nom: Value('litre'),
        typeGrandeur: Value(TypeGrandeur.volume),
        facteurVersBase: Value(1000),
      ),
      UnitesCompanion(
        nom: Value('cuillère à café'),
        typeGrandeur: Value(TypeGrandeur.volume),
        facteurVersBase: Value(5),
      ),
      UnitesCompanion(
        nom: Value('cuillère à soupe'),
        typeGrandeur: Value(TypeGrandeur.volume),
        facteurVersBase: Value(15),
      ),
      UnitesCompanion(
        nom: Value('pièce'),
        typeGrandeur: Value(TypeGrandeur.unite),
        facteurVersBase: Value(1),
      ),
    ]);
  });
}
