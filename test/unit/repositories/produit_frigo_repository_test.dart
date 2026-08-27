import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/produit_frigo_repository.dart';
import 'package:miamo/data/repositories/produit_repository.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late ProduitFrigoRepository repo;
  late ProduitRepository produitRepo;
  late int produitId;

  setUp(() async {
    db = createTestDatabase();
    repo = ProduitFrigoRepository(db);
    produitRepo = ProduitRepository(db);
    final produit = await produitRepo.create(
      nom: 'Tomate',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.masse,
      uniteDefautId: 1,
    );
    produitId = produit.id;
  });

  tearDown(() => db.close());

  test('create ajoute une instance en_stock et remonte le produit', () async {
    final instance = await repo.create(
      produitId: produitId,
      zoneId: 1,
      quantite: 2,
      uniteId: 1,
      datePeremption: DateTime(2026, 12, 31),
    );

    expect(instance.statut, StatutProduitFrigo.enStock);
    final produit = await produitRepo.getById(produitId);
    expect(produit.dateDerniereUtilisation, isNotNull);
  });

  test('watchEnStock trie par urgence (péremption la plus proche en premier, '
      'sans date en dernier)', () async {
    await repo.create(
      produitId: produitId,
      zoneId: 1,
      quantite: 1,
      uniteId: 1,
      datePeremption: null,
    );
    await repo.create(
      produitId: produitId,
      zoneId: 1,
      quantite: 1,
      uniteId: 1,
      datePeremption: DateTime(2026, 9, 1),
    );
    await repo.create(
      produitId: produitId,
      zoneId: 1,
      quantite: 1,
      uniteId: 1,
      datePeremption: DateTime(2026, 8, 25),
    );

    final liste = await repo.watchEnStock().first;
    expect(liste.length, 3);
    expect(liste[0].instance.datePeremption, DateTime(2026, 8, 25));
    expect(liste[1].instance.datePeremption, DateTime(2026, 9, 1));
    expect(liste[2].instance.datePeremption, isNull);
  });

  test(
    'marquerConsomme / marquerJete retirent l\'instance de watchEnStock',
    () async {
      final consomme = await repo.create(
        produitId: produitId,
        zoneId: 1,
        quantite: 1,
        uniteId: 1,
      );
      final jete = await repo.create(
        produitId: produitId,
        zoneId: 1,
        quantite: 1,
        uniteId: 1,
      );

      await repo.marquerConsomme(consomme.id);
      await repo.marquerJete(jete.id);

      final enStock = await repo.watchEnStock().first;
      expect(enStock, isEmpty);
    },
  );

  test('supprimerInstance supprime la ligne sans changer de statut', () async {
    final instance = await repo.create(
      produitId: produitId,
      zoneId: 1,
      quantite: 1,
      uniteId: 1,
    );

    await repo.supprimerInstance(instance.id);

    expect(
      await (db.select(
        db.produitsFrigo,
      )..where((t) => t.id.equals(instance.id))).getSingleOrNull(),
      isNull,
    );
  });
}
