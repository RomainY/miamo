import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/plat_repository.dart';
import 'package:miamo/data/repositories/produit_frigo_repository.dart';
import 'package:miamo/data/repositories/produit_repository.dart';
import 'package:miamo/data/repositories/repas_planifie_repository.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late RepasPlanifieRepository repo;
  late ProduitFrigoRepository frigoRepo;
  late int produitId;

  setUp(() async {
    db = createTestDatabase();
    repo = RepasPlanifieRepository(db);
    frigoRepo = ProduitFrigoRepository(db);
    final produit = await ProduitRepository(db).create(
      nom: 'Riz',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.masse,
      uniteDefautId: 1, // gramme
    );
    produitId = produit.id;
  });

  tearDown(() => db.close());

  test('planifier refuse si ni plat ni produit (ou les deux)', () async {
    expect(
      () => repo.planifier(date: DateTime(2026, 9, 1), portions: 2),
      throwsArgumentError,
    );
  });

  test('marquerFait décompte le frigo depuis les ingrédients du plat '
      '(FIFO par péremption)', () async {
    // kilogramme (id=2, facteur 1000) vs gramme (id=1, facteur 1) : même
    // type_grandeur (masse), conversion attendue.
    final plat = await PlatRepository(db).create(
      nom: 'Riz cantonais',
      portionsDefaut: 2,
      ingredients: [
        IngredientInput(produitId: produitId, quantite: 300, uniteId: 1),
      ],
    );

    final ancien = await frigoRepo.create(
      produitId: produitId,
      zoneId: 1,
      quantite: 0.2, // 200g, en kg
      uniteId: 2,
      datePeremption: DateTime(2026, 8, 25),
    );
    final recent = await frigoRepo.create(
      produitId: produitId,
      zoneId: 1,
      quantite: 500, // 500g
      uniteId: 1,
      datePeremption: DateTime(2026, 9, 10),
    );

    final repas = await repo.planifier(
      date: DateTime(2026, 8, 20),
      platId: plat.id,
      portions: 2, // = portions_defaut, ratio 1 -> besoin 300g
    );

    await repo.marquerFait(repas.id);

    final ancienApres = await frigoRepo.getById(ancien.id);
    final recentApres = await frigoRepo.getById(recent.id);

    // La ligne la plus urgente (200g) est entièrement consommée en premier.
    expect(ancienApres.statut, StatutProduitFrigo.consomme);
    // Reste 100g à prendre sur la ligne suivante (500g -> 400g restants).
    expect(recentApres.statut, StatutProduitFrigo.enStock);
    expect(recentApres.quantite, closeTo(400, 0.001));

    final repasApres = await repo.getById(repas.id);
    expect(repasApres.statut, StatutRepas.fait);
  });

  test('marquerFait sur un produit isolé décompte "portions" en unité par '
      'défaut du produit', () async {
    final instance = await frigoRepo.create(
      produitId: produitId,
      zoneId: 1,
      quantite: 500,
      uniteId: 1,
    );

    final repas = await repo.planifier(
      date: DateTime(2026, 8, 20),
      produitId: produitId,
      portions: 150,
    );
    await repo.marquerFait(repas.id);

    final instanceApres = await frigoRepo.getById(instance.id);
    expect(instanceApres.quantite, closeTo(350, 0.001));
  });

  test('marquerFait ne bloque pas en cas de stock insuffisant', () async {
    final repas = await repo.planifier(
      date: DateTime(2026, 8, 20),
      produitId: produitId,
      portions: 100,
    );

    await repo.marquerFait(repas.id);

    final repasApres = await repo.getById(repas.id);
    expect(repasApres.statut, StatutRepas.fait);
  });

  test('marquerFait sur un repas non "planifié" lève et ne décompte rien '
      '(échec visible, cf. audit BP-06)', () async {
    final instance = await frigoRepo.create(
      produitId: produitId,
      zoneId: 1,
      quantite: 500,
      uniteId: 1,
    );
    final repas = await repo.planifier(
      date: DateTime(2026, 8, 20),
      produitId: produitId,
      portions: 150,
    );
    await repo.marquerFait(repas.id);

    // Deuxième appel : le repas est déjà "fait".
    await expectLater(repo.marquerFait(repas.id), throwsStateError);

    // La transaction a été annulée : le stock n'a été décompté qu'une fois.
    final instanceApres = await frigoRepo.getById(instance.id);
    expect(instanceApres.quantite, closeTo(350, 0.001));
  });

  test('annuler puis marquerFait lève également', () async {
    final repas = await repo.planifier(
      date: DateTime(2026, 8, 20),
      produitId: produitId,
      portions: 10,
    );
    await repo.annuler(repas.id);
    await expectLater(repo.marquerFait(repas.id), throwsStateError);
  });

  test('watchPlanifiesDetail ne renvoie que les repas "planifié", toutes '
      'dates confondues', () async {
    final plat = await PlatRepository(
      db,
    ).create(nom: 'Riz cantonais', portionsDefaut: 2);

    // Repas passé, toujours planifié.
    final passe = await repo.planifier(
      date: DateTime(2020, 1, 1),
      platId: plat.id,
      portions: 2,
    );
    // Repas futur qu'on annule.
    final annule = await repo.planifier(
      date: DateTime(2030, 1, 1),
      produitId: produitId,
      portions: 3,
    );
    await repo.annuler(annule.id);

    final details = await repo.watchPlanifiesDetail().first;
    expect(details.map((d) => d.repas.id), [passe.id]);

    // Réactif : marquer le dernier repas planifié "fait" vide la liste.
    await repo.marquerFait(passe.id);
    expect(await repo.watchPlanifiesDetail().first, isEmpty);
  });

  test(
    'watchProchainsDetail résout le plat ou le produit isolé associé',
    () async {
      final plat = await PlatRepository(
        db,
      ).create(nom: 'Riz cantonais', portionsDefaut: 2);
      await repo.planifier(
        date: DateTime.now().add(const Duration(days: 1)),
        platId: plat.id,
        portions: 2,
      );
      await repo.planifier(
        date: DateTime.now().add(const Duration(days: 2)),
        produitId: produitId,
        portions: 3,
      );

      final details = await repo.watchProchainsDetail().first;

      expect(details, hasLength(2));
      final detailPlat = details.firstWhere((d) => d.repas.platId != null);
      expect(detailPlat.titre, 'Riz cantonais');
      expect(detailPlat.produit, isNull);

      final detailProduit = details.firstWhere(
        (d) => d.repas.produitId != null,
      );
      expect(detailProduit.titre, 'Riz');
      expect(detailProduit.plat, isNull);
    },
  );
}
