import 'package:drift/drift.dart' hide isNull;
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

  group('code-barres (v1.1)', () {
    test('getByCodeBarre retrouve le produit, null si code inconnu', () async {
      final cree = await repo.create(
        nom: 'Yaourt nature',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
        codeBarre: '3033710065967',
      );

      final trouve = await repo.getByCodeBarre('3033710065967');
      expect(trouve?.id, cree.id);
      expect(await repo.getByCodeBarre('0000000000000'), isNull);
    });

    test('getByCodeBarre retourne aussi un produit archivé', () async {
      final cree = await repo.create(
        nom: 'Café moulu',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
        codeBarre: '3033710065912',
      );
      await repo.archiver(cree.id);

      final trouve = await repo.getByCodeBarre('3033710065912');
      expect(trouve?.id, cree.id);
      expect(trouve?.statut, StatutProduit.archive);
    });

    test('create rejette un code-barres déjà utilisé', () async {
      await repo.create(
        nom: 'Lait demi-écrémé',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.volume,
        uniteDefautId: 3,
        codeBarre: '3520836011234',
      );

      expect(
        () => repo.create(
          nom: 'Lait entier',
          categorieId: 1,
          typeGrandeur: TypeGrandeur.volume,
          uniteDefautId: 3,
          codeBarre: '3520836011234',
        ),
        throwsA(isA<DuplicateBarcodeException>()),
      );
    });

    test('plusieurs produits sans code-barres coexistent', () async {
      await repo.create(
        nom: 'Tomate',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
      );
      await repo.create(
        nom: 'Carotte',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
      );

      final tous = await repo.watchAll().first;
      expect(tous.where((p) => p.codeBarre == null), hasLength(2));
    });

    test('update pose, puis retire le code-barres (tri-état Value)', () async {
      final cree = await repo.create(
        nom: 'Beurre doux',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
      );

      // Value.absent() (défaut) : le code n'est pas touché.
      await repo.update(cree.id, nom: 'Beurre doux 250g');
      expect((await repo.getById(cree.id)).codeBarre, isNull);

      // Value('...') : on pose un code.
      await repo.update(cree.id, codeBarre: const Value('3256540001234'));
      expect((await repo.getById(cree.id)).codeBarre, '3256540001234');

      // Value(null) : on retire le code.
      await repo.update(cree.id, codeBarre: const Value(null));
      expect((await repo.getById(cree.id)).codeBarre, isNull);
    });

    test('update rejette un code déjà porté par un autre produit', () async {
      await repo.create(
        nom: 'Produit A',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
        codeBarre: '3017620422003',
      );
      final b = await repo.create(
        nom: 'Produit B',
        categorieId: 1,
        typeGrandeur: TypeGrandeur.masse,
        uniteDefautId: 1,
      );

      expect(
        () => repo.update(b.id, codeBarre: const Value('3017620422003')),
        throwsA(isA<DuplicateBarcodeException>()),
      );
    });
  });
}
