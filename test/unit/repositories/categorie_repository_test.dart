import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/categorie_repository.dart';
import 'package:miamo/shared/utils/exceptions.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late CategorieRepository repo;

  setUp(() {
    db = createTestDatabase();
    repo = CategorieRepository(db);
  });

  tearDown(() => db.close());

  test('seed crée "Non classé" comme catégorie par défaut', () async {
    final defaut = await repo.getDefault();
    expect(defaut.nom, 'Non classé');
    expect(defaut.estParDefaut, isTrue);
  });

  test('create rejette un nom déjà utilisé', () async {
    await repo.create(nom: 'Frais');
    expect(
      () => repo.create(nom: 'Frais'),
      throwsA(isA<DuplicateNameException>()),
    );
  });

  test('update peut renommer la catégorie par défaut', () async {
    final defaut = await repo.getDefault();
    final renommee = await repo.update(defaut.id, nom: 'Sans catégorie');
    expect(renommee.nom, 'Sans catégorie');
    expect(renommee.estParDefaut, isTrue);
  });

  test('delete de la catégorie par défaut est bloqué', () async {
    final defaut = await repo.getDefault();
    expect(
      () => repo.delete(defaut.id),
      throwsA(isA<ElementProtegeException>()),
    );
  });

  test('delete réaffecte les produits vers "Non classé"', () async {
    final categorie = await repo.create(nom: 'Frais');
    final produitId = await db
        .into(db.produits)
        .insert(
          ProduitsCompanion.insert(
            nom: 'Tomate',
            categorieId: categorie.id,
            typeGrandeur: TypeGrandeur.masse,
            uniteDefautId: 1,
          ),
        );

    await repo.delete(categorie.id);

    final produit = await (db.select(
      db.produits,
    )..where((t) => t.id.equals(produitId))).getSingle();
    final defaut = await repo.getDefault();
    expect(produit.categorieId, defaut.id);
  });
}
