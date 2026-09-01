import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/produit_repository.dart';
import 'package:miamo/shared/utils/exceptions.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late ProduitRepository repo;

  setUp(() {
    db = createTestDatabase();
    repo = ProduitRepository(db);
  });

  tearDown(() => db.close());

  test(
    'create rejette une unité incompatible avec le type de grandeur',
    () async {
      // unite id=3 (millilitre, volume) seedée, incompatible avec masse.
      expect(
        () => repo.create(
          nom: 'Tomate',
          categorieId: 1,
          typeGrandeur: TypeGrandeur.masse,
          uniteDefautId: 3,
        ),
        throwsArgumentError,
      );
    },
  );

  test('create rejette un nom déjà utilisé', () async {
    await repo.create(
      nom: 'Tomate',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.masse,
      uniteDefautId: 1,
    );
    expect(
      () => repo.create(
        nom: 'Tomate',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
      ),
      throwsA(isA<DuplicateNameException>()),
    );
  });

  test('watchAll trie sans tenir compte de la casse ni des accents', () async {
    for (final nom in ['Épinard', 'avocat', 'elan', 'Œuf', 'zébu']) {
      await repo.create(
        nom: nom,
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
      );
    }

    final noms = (await repo.watchAll().first).map((p) => p.nom).toList();
    expect(noms, ['avocat', 'elan', 'Épinard', 'Œuf', 'zébu']);
  });

  test('archiver retire le produit de watchActifs', () async {
    final produit = await repo.create(
      nom: 'Tomate',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.masse,
      uniteDefautId: 1,
    );

    await repo.archiver(produit.id);
    final actifs = await repo.watchActifs().first;
    expect(actifs.any((p) => p.id == produit.id), isFalse);

    await repo.desarchiver(produit.id);
    final actifsApresDesarchivage = await repo.watchActifs().first;
    expect(actifsApresDesarchivage.any((p) => p.id == produit.id), isTrue);
  });

  test(
    'supprimerDefinitivement est bloqué tant que le produit est actif',
    () async {
      final produit = await repo.create(
        nom: 'Tomate',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
      );
      expect(
        () => repo.supprimerDefinitivement(produit.id),
        throwsA(isA<ProduitNonArchiveException>()),
      );
    },
  );

  test('supprimerDefinitivement supprime en cascade instances/ingrédients/'
      'articles/repas liés', () async {
    final produit = await repo.create(
      nom: 'Tomate',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.masse,
      uniteDefautId: 1,
    );

    await db
        .into(db.produitsFrigo)
        .insert(
          ProduitsFrigoCompanion.insert(
            produitId: produit.id,
            zoneId: 1,
            quantite: 1,
            uniteId: 1,
            dateAjout: DateTime(2026, 1, 1),
          ),
        );
    final platId = await db
        .into(db.plats)
        .insert(
          PlatsCompanion.insert(nom: 'Salade', portionsDefaut: const Value(2)),
        );
    await db
        .into(db.platIngredients)
        .insert(
          PlatIngredientsCompanion.insert(
            platId: platId,
            produitId: produit.id,
            quantite: 1,
            uniteId: 1,
          ),
        );
    await db
        .into(db.articlesCourse)
        .insert(
          ArticlesCourseCompanion.insert(
            produitId: produit.id,
            quantite: 1,
            uniteId: 1,
          ),
        );
    await db
        .into(db.repasPlanifies)
        .insert(
          RepasPlanifiesCompanion.insert(
            date: DateTime(2026, 1, 2),
            produitId: Value(produit.id),
            portions: 1,
          ),
        );

    final preview = await repo.previewSuppressionCascade(produit.id);
    expect(preview.instancesFrigo, 1);
    expect(preview.ingredientsPlat, 1);
    expect(preview.articlesCourse, 1);
    expect(preview.repasPlanifies, 1);

    await repo.archiver(produit.id);
    await repo.supprimerDefinitivement(produit.id);

    expect(
      await (db.select(
        db.produitsFrigo,
      )..where((t) => t.produitId.equals(produit.id))).get(),
      isEmpty,
    );
    expect(
      await (db.select(
        db.platIngredients,
      )..where((t) => t.produitId.equals(produit.id))).get(),
      isEmpty,
    );
    // Le plat lui-même n'est pas supprimé.
    expect(
      await (db.select(db.plats)..where((t) => t.id.equals(platId))).get(),
      isNotEmpty,
    );
  });
}
