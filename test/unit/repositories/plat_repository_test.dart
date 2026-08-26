import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/plat_repository.dart';
import 'package:miamo/data/repositories/produit_repository.dart';
import 'package:miamo/data/repositories/repas_planifie_repository.dart';
import 'package:miamo/shared/utils/exceptions.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late PlatRepository repo;
  late int produitId;

  setUp(() async {
    db = createTestDatabase();
    repo = PlatRepository(db);
    final produit = await ProduitRepository(db).create(
      nom: 'Riz',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.masse,
      uniteDefautId: 1,
    );
    produitId = produit.id;
  });

  tearDown(() => db.close());

  test('create écrit le plat et ses ingrédients', () async {
    final plat = await repo.create(
      nom: 'Riz cantonais',
      portionsDefaut: 2,
      ingredients: [
        IngredientInput(produitId: produitId, quantite: 200, uniteId: 1),
      ],
    );

    final ingredients = await repo.watchIngredients(plat.id).first;
    expect(ingredients, hasLength(1));
    expect(ingredients.first.ingredient.quantite, 200);
  });

  test('remplacerIngredients écrase la liste précédente', () async {
    final plat = await repo.create(
      nom: 'Riz cantonais',
      portionsDefaut: 2,
      ingredients: [
        IngredientInput(produitId: produitId, quantite: 200, uniteId: 1),
      ],
    );

    await repo.remplacerIngredients(plat.id, [
      IngredientInput(produitId: produitId, quantite: 350, uniteId: 1),
    ]);

    final ingredients = await repo.watchIngredients(plat.id).first;
    expect(ingredients, hasLength(1));
    expect(ingredients.first.ingredient.quantite, 350);
  });

  test('delete est bloqué si le plat est utilisé par un repas planifié', () async {
    final plat = await repo.create(nom: 'Riz cantonais', portionsDefaut: 2);
    await RepasPlanifieRepository(
      db,
    ).planifier(date: DateTime(2026, 9, 1), platId: plat.id, portions: 2);

    expect(
      () => repo.delete(plat.id),
      throwsA(isA<ReferenceActiveException>()),
    );
  });
}
