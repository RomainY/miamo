import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/plat_repository.dart';
import 'package:miamo/data/repositories/produit_frigo_repository.dart';
import 'package:miamo/data/repositories/produit_repository.dart';
import 'package:miamo/data/repositories/repas_planifie_repository.dart';
import 'package:miamo/features/planification/domain/disponibilite_ingredients.dart';

import '../repositories/test_database.dart';

/// Unités seedées : 1 gramme (masse, 1), 2 kilogramme (masse, 1000),
/// 3 millilitre (volume, 1).
void main() {
  late AppDatabase db;
  late ProduitRepository produitRepo;
  late ProduitFrigoRepository frigoRepo;
  late PlatRepository platRepo;
  late RepasPlanifieRepository repasRepo;

  setUp(() {
    db = createTestDatabase();
    produitRepo = ProduitRepository(db);
    frigoRepo = ProduitFrigoRepository(db);
    platRepo = PlatRepository(db);
    repasRepo = RepasPlanifieRepository(db);
  });

  tearDown(() => db.close());

  Future<int> creerProduit(
    String nom, {
    TypeGrandeur grandeur = TypeGrandeur.masse,
    int uniteDefautId = 1,
  }) async {
    final p = await produitRepo.create(
      nom: nom,
      categorieId: 1,
      typeGrandeur: grandeur,
      uniteDefautId: uniteDefautId,
    );
    return p.id;
  }

  /// Assemble les entrées du calcul depuis la base et renvoie le résultat de
  /// [calculerDisponibilites].
  Future<Map<int, DisponibiliteRepas>> calculer() async {
    final stock = await frigoRepo.watchEnStock().first;
    final repas = await repasRepo.watchPlanifiesDetail().first;
    final lignesIngredients = await platRepo.watchTousIngredients().first;
    final ingredientsParPlat = <int, List<PlatIngredient>>{};
    for (final ing in lignesIngredients) {
      (ingredientsParPlat[ing.platId] ??= []).add(ing);
    }
    final unites = {for (final u in await db.select(db.unites).get()) u.id: u};
    final produits = {
      for (final p in await db.select(db.produits).get()) p.id: p,
    };

    return calculerDisponibilites(
      repasPlanifies: repas,
      stock: stock,
      ingredientsParPlat: ingredientsParPlat,
      unitesParId: unites,
      produitsParId: produits,
    );
  }

  test('ingrédient absent du frigo -> manquant', () async {
    final beurre = await creerProduit('Beurre');
    final plat = await platRepo.create(
      nom: 'Gâteau',
      portionsDefaut: 1,
      ingredients: [
        IngredientInput(produitId: beurre, quantite: 100, uniteId: 1),
      ],
    );
    final repas = await repasRepo.planifier(
      date: DateTime(2026, 9, 1),
      platId: plat.id,
      portions: 1,
    );

    final dispo = (await calculer())[repas.id]!;
    expect(dispo.global, ManqueIngredient.manquant);
    expect(dispo.manques.single.produitNom, 'Beurre');
    expect(dispo.manques.single.requis, 100);
    expect(dispo.manques.single.disponible, 0);
  });

  test('stock inférieur au besoin -> insuffisant, avec requis/disponible', () async {
    final riz = await creerProduit('Riz');
    await frigoRepo.create(
      produitId: riz,
      zoneId: 1,
      quantite: 100,
      uniteId: 1,
    );
    final plat = await platRepo.create(
      nom: 'Riz pilaf',
      portionsDefaut: 1,
      ingredients: [IngredientInput(produitId: riz, quantite: 300, uniteId: 1)],
    );
    final repas = await repasRepo.planifier(
      date: DateTime(2026, 9, 1),
      platId: plat.id,
      portions: 1,
    );

    final dispo = (await calculer())[repas.id]!;
    expect(dispo.global, ManqueIngredient.insuffisant);
    expect(dispo.manques.single.requis, 300);
    expect(dispo.manques.single.disponible, 100);
  });

  test('conversion kg -> g : 0,2 kg couvre un besoin de 150 g', () async {
    final riz = await creerProduit('Riz');
    await frigoRepo.create(
      produitId: riz,
      zoneId: 1,
      quantite: 0.2, // 200 g exprimés en kilogrammes
      uniteId: 2,
    );
    final plat = await platRepo.create(
      nom: 'Riz',
      portionsDefaut: 1,
      ingredients: [IngredientInput(produitId: riz, quantite: 150, uniteId: 1)],
    );
    final repas = await repasRepo.planifier(
      date: DateTime(2026, 9, 1),
      platId: plat.id,
      portions: 1,
    );

    final dispo = (await calculer())[repas.id];
    expect(dispo!.ok, isTrue);
  });

  test('grandeur incompatible (besoin volume, stock masse) -> manquant', () async {
    final lait = await creerProduit(
      'Lait',
      grandeur: TypeGrandeur.volume,
      uniteDefautId: 3,
    );
    // Instance stockée en grammes (masse) : incompatible avec un besoin en ml.
    await frigoRepo.create(
      produitId: lait,
      zoneId: 1,
      quantite: 500,
      uniteId: 1,
    );
    final plat = await platRepo.create(
      nom: 'Béchamel',
      portionsDefaut: 1,
      ingredients: [IngredientInput(produitId: lait, quantite: 200, uniteId: 3)],
    );
    final repas = await repasRepo.planifier(
      date: DateTime(2026, 9, 1),
      platId: plat.id,
      portions: 1,
    );

    final dispo = (await calculer())[repas.id]!;
    expect(dispo.global, ManqueIngredient.manquant);
  });

  test('allocation cumulée : le 1er repas passe, le 2e manque de stock', () async {
    final riz = await creerProduit('Riz');
    await frigoRepo.create(
      produitId: riz,
      zoneId: 1,
      quantite: 500,
      uniteId: 1,
    );
    final plat = await platRepo.create(
      nom: 'Riz',
      portionsDefaut: 1,
      ingredients: [IngredientInput(produitId: riz, quantite: 300, uniteId: 1)],
    );
    final r1 = await repasRepo.planifier(
      date: DateTime(2026, 9, 1),
      platId: plat.id,
      portions: 1,
    );
    final r2 = await repasRepo.planifier(
      date: DateTime(2026, 9, 2),
      platId: plat.id,
      portions: 1,
    );

    final dispos = await calculer();
    expect(dispos[r1.id]!.ok, isTrue);
    expect(dispos[r2.id]!.global, ManqueIngredient.insuffisant);
    expect(dispos[r2.id]!.manques.single.disponible, 200);
  });

  test('ratio de portions : portions x2 double le besoin', () async {
    final riz = await creerProduit('Riz');
    await frigoRepo.create(
      produitId: riz,
      zoneId: 1,
      quantite: 300,
      uniteId: 1,
    );
    final plat = await platRepo.create(
      nom: 'Riz',
      portionsDefaut: 2,
      ingredients: [IngredientInput(produitId: riz, quantite: 200, uniteId: 1)],
    );
    final repas = await repasRepo.planifier(
      date: DateTime(2026, 9, 1),
      platId: plat.id,
      portions: 4, // ratio 2 -> besoin 400 g
    );

    final dispo = (await calculer())[repas.id]!;
    expect(dispo.global, ManqueIngredient.insuffisant);
    expect(dispo.manques.single.requis, 400);
  });

  test('repas "produit isolé" : portions interprétées comme quantité', () async {
    final riz = await creerProduit('Riz');
    await frigoRepo.create(
      produitId: riz,
      zoneId: 1,
      quantite: 100,
      uniteId: 1,
    );
    final repas = await repasRepo.planifier(
      date: DateTime(2026, 9, 1),
      produitId: riz,
      portions: 250,
    );

    final dispo = (await calculer())[repas.id]!;
    expect(dispo.global, ManqueIngredient.insuffisant);
    expect(dispo.manques.single.requis, 250);
    expect(dispo.manques.single.disponible, 100);
  });

  test('plat sans ingrédient : absent de la map de résultats', () async {
    final plat = await platRepo.create(nom: 'Eau chaude', portionsDefaut: 1);
    final repas = await repasRepo.planifier(
      date: DateTime(2026, 9, 1),
      platId: plat.id,
      portions: 1,
    );

    expect((await calculer()).containsKey(repas.id), isFalse);
  });

  test('repas marqué fait : sorti de l\'allocation cumulée', () async {
    final riz = await creerProduit('Riz');
    await frigoRepo.create(
      produitId: riz,
      zoneId: 1,
      quantite: 300,
      uniteId: 1,
    );
    final plat = await platRepo.create(
      nom: 'Riz',
      portionsDefaut: 1,
      ingredients: [IngredientInput(produitId: riz, quantite: 300, uniteId: 1)],
    );
    final rFait = await repasRepo.planifier(
      date: DateTime(2026, 9, 1),
      platId: plat.id,
      portions: 1,
    );
    final rPlanifie = await repasRepo.planifier(
      date: DateTime(2026, 9, 2),
      platId: plat.id,
      portions: 1,
    );
    await repasRepo.marquerFait(rFait.id);

    final dispos = await calculer();
    expect(dispos.containsKey(rFait.id), isFalse);
    // marquerFait a consommé les 300 g -> il ne reste rien pour rPlanifie.
    expect(dispos[rPlanifie.id]!.global, ManqueIngredient.manquant);
  });

  test('evaluerCandidat : aperçu sans consommer le pool', () async {
    final riz = await creerProduit('Riz');
    await frigoRepo.create(
      produitId: riz,
      zoneId: 1,
      quantite: 500,
      uniteId: 1,
    );
    final plat = await platRepo.create(
      nom: 'Riz',
      portionsDefaut: 1,
      ingredients: [IngredientInput(produitId: riz, quantite: 300, uniteId: 1)],
    );
    final platRow = await platRepo.getById(plat.id);
    final ingredients = {
      plat.id: await db.select(db.platIngredients).get(),
    };
    final unites = {for (final u in await db.select(db.unites).get()) u.id: u};
    final produits = {
      for (final p in await db.select(db.produits).get()) p.id: p,
    };
    final stock = await frigoRepo.watchEnStock().first;

    final pool = construirePool(stock);
    final ok = evaluerCandidat(
      pool: pool,
      plat: platRow,
      portions: 1,
      ingredientsParPlat: ingredients,
      unitesParId: unites,
      produitsParId: produits,
    );
    expect(ok!.ok, isTrue);
    // Pool inchangé : une 2e évaluation identique passe encore.
    final encore = evaluerCandidat(
      pool: pool,
      plat: platRow,
      portions: 1,
      ingredientsParPlat: ingredients,
      unitesParId: unites,
      produitsParId: produits,
    );
    expect(encore!.ok, isTrue);
  });
}
