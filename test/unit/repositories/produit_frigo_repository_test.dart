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

  group('retirerUn (raccourci -1, demande du 11/09/2026)', () {
    test('décrémente la quantité d\'une unité sans changer de statut', () async {
      final instance = await repo.create(
        produitId: produitId,
        zoneId: 1,
        quantite: 6,
        uniteId: 1,
      );

      await repo.retirerUn(instance.id);

      final relue = await repo.getById(instance.id);
      expect(relue.quantite, 5);
      expect(relue.statut, StatutProduitFrigo.enStock);
    });

    test('à 0, passe automatiquement à consomme (dateStatut posée)', () async {
      final instance = await repo.create(
        produitId: produitId,
        zoneId: 1,
        quantite: 1,
        uniteId: 1,
      );

      await repo.retirerUn(instance.id);

      final relue = await repo.getById(instance.id);
      expect(relue.quantite, 0);
      expect(relue.statut, StatutProduitFrigo.consomme);
      expect(relue.dateStatut, isNotNull);

      final enStock = await repo.watchEnStock().first;
      expect(enStock, isEmpty);
    });
  });

  group('watchHistoriqueRecent (poc-liste-courses-auto.md §3.2)', () {
    test('inclut consomme et jete, exclut une suppression directe', () async {
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
      final supprime = await repo.create(
        produitId: produitId,
        zoneId: 1,
        quantite: 1,
        uniteId: 1,
      );

      await repo.marquerConsomme(consomme.id);
      await repo.marquerJete(jete.id);
      await repo.supprimerInstance(supprime.id);

      final historique = await repo
          .watchHistoriqueRecent(DateTime.now().subtract(const Duration(days: 1)))
          .first;

      expect(historique, hasLength(2));
      expect(
        historique.map((h) => h.statut),
        containsAll([StatutProduitFrigo.consomme, StatutProduitFrigo.jete]),
      );
    });

    test('exclut ce qui est antérieur à la borne [depuis]', () async {
      final instance = await repo.create(
        produitId: produitId,
        zoneId: 1,
        quantite: 1,
        uniteId: 1,
      );
      await repo.marquerConsomme(instance.id);

      final historique = await repo
          .watchHistoriqueRecent(DateTime.now().add(const Duration(days: 1)))
          .first;

      expect(historique, isEmpty);
    });
  });
}
