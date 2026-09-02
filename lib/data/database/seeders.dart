import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

/// Catégories de base créées au premier lancement (en plus de « Non classé »),
/// pour éviter d'avoir un catalogue vide et **faire atterrir directement le
/// mapping des produits scannés** (`shared/utils/off_category_mapping.dart` :
/// chaque bucket Open Food Facts correspond à l'un de ces noms). L'utilisateur
/// reste libre de les renommer ou de les supprimer (réaffectation vers
/// « Non classé »). Réinjectées dans les bases existantes par la migration
/// v3 → v4 (`INSERT OR IGNORE`, cf. `app_database.dart`).
const categoriesDeBase = <String>[
  'Frais',
  'Fruits & légumes',
  'Viandes & poissons',
  'Féculents',
  'Épicerie salée',
  'Épicerie sucrée',
  'Petit-déjeuner',
  'Boissons',
  'Surgelés',
];

/// Seed exécuté une seule fois, à la création de la base (cf.
/// documentation-technique.md §2) :
/// - catégorie par défaut "Non classé" (réaffectation, non supprimable)
///   + les [categoriesDeBase] (renommables / supprimables)
/// - zone racine "Frigo" (is_root = true, réaffectation, non supprimable)
/// - unités de base pour chaque type_grandeur
Future<void> seedInitialData(AppDatabase db) async {
  await db
      .into(db.categories)
      .insert(
        const CategoriesCompanion(
          nom: Value('Non classé'),
          icone: Value('category'),
          estParDefaut: Value(true),
        ),
      );

  await db.batch((batch) {
    batch.insertAll(db.categories, [
      for (final nom in categoriesDeBase) CategoriesCompanion.insert(nom: nom),
    ]);
  });

  await db
      .into(db.zones)
      .insert(
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
