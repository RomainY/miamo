import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/article_course_repository.dart';
import 'package:miamo/data/repositories/plat_repository.dart';
import 'package:miamo/data/repositories/produit_frigo_repository.dart';
import 'package:miamo/data/repositories/produit_repository.dart';
import 'package:miamo/data/repositories/repas_planifie_repository.dart';
import 'package:miamo/features/courses/domain/suggestions_courses.dart';
import 'package:miamo/features/planification/domain/disponibilite_ingredients.dart';

import '../repositories/test_database.dart';

/// Unités seedées : 1 gramme (masse, 1), 2 kilogramme (masse, 1000),
/// 3 millilitre (volume, 1).
void main() {
  late AppDatabase db;
  late ProduitRepository produitRepo;
  late ProduitFrigoRepository frigoRepo;
  late RepasPlanifieRepository repasRepo;
  late ArticleCourseRepository articleRepo;

  setUp(() {
    db = createTestDatabase();
    produitRepo = ProduitRepository(db);
    frigoRepo = ProduitFrigoRepository(db);
    repasRepo = RepasPlanifieRepository(db);
    articleRepo = ArticleCourseRepository(db);
  });

  tearDown(() => db.close());

  Future<Produit> creerProduit(
    String nom, {
    TypeGrandeur grandeur = TypeGrandeur.masse,
    int uniteDefautId = 1,
  }) {
    return produitRepo.create(
      nom: nom,
      categorieId: 1,
      typeGrandeur: grandeur,
      uniteDefautId: uniteDefautId,
    );
  }

  Future<Map<int, Unite>> unites() async => {
    for (final u in await db.select(db.unites).get()) u.id: u,
  };

  group('calculerSuggestionsPlanification', () {
    test('ingrédient manquant -> suggestion en unité par défaut du produit', () async {
      final beurre = await creerProduit('Beurre');
      final plat = await PlatRepository(db).create(
        nom: 'Gâteau',
        portionsDefaut: 1,
        ingredients: [
          IngredientInput(produitId: beurre.id, quantite: 100, uniteId: 1),
        ],
      );
      final repas = await repasRepo.planifier(
        date: DateTime(2026, 9, 1),
        platId: plat.id,
        portions: 1,
      );

      final repasDetail = (await repasRepo.watchPlanifiesDetail().first);
      final ingredients = <int, List<PlatIngredient>>{
        plat.id: await db.select(db.platIngredients).get(),
      };
      final produits = {
        for (final p in await db.select(db.produits).get()) p.id: p,
      };
      final u = await unites();

      final suggestions = calculerSuggestionsPlanification(
        repasPlanifies: repasDetail,
        stock: await frigoRepo.watchEnStock().first,
        ingredientsParPlat: ingredients,
        unitesParId: u,
        produitsParId: produits,
        articlesActifs: const [],
        repasParId: {for (final r in repasDetail) r.repas.id: r},
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.single.produitId, beurre.id);
      expect(suggestions.single.quantite, 100);
      expect(suggestions.single.origine, OrigineArticle.suggestionPlanification);
      expect(suggestions.single.raison, contains('Gâteau'));
      expect(suggestions.single.raison, contains('01/09'));
      // repas non utilisé plus loin, garde le import propre.
      expect(repas.statut, StatutRepas.planifie);
    });

    test('article déjà en liste couvrant tout le besoin -> aucune suggestion', () async {
      final riz = await creerProduit('Riz');
      final plat = await PlatRepository(db).create(
        nom: 'Riz',
        portionsDefaut: 1,
        ingredients: [
          IngredientInput(produitId: riz.id, quantite: 300, uniteId: 1),
        ],
      );
      await repasRepo.planifier(
        date: DateTime(2026, 9, 1),
        platId: plat.id,
        portions: 1,
      );
      final articleExistant = await articleRepo.ajouter(
        produitId: riz.id,
        quantite: 300,
        uniteId: 1,
      );

      final repasDetail = await repasRepo.watchPlanifiesDetail().first;
      final ingredients = <int, List<PlatIngredient>>{
        plat.id: await db.select(db.platIngredients).get(),
      };
      final produits = {
        for (final p in await db.select(db.produits).get()) p.id: p,
      };
      final u = await unites();
      final articlesActifs = [
        ArticleCourseDetail(
          article: articleExistant,
          produit: produits[riz.id]!,
          unite: u[1]!,
        ),
      ];

      final suggestions = calculerSuggestionsPlanification(
        repasPlanifies: repasDetail,
        stock: const [],
        ingredientsParPlat: ingredients,
        unitesParId: u,
        produitsParId: produits,
        articlesActifs: articlesActifs,
        repasParId: {for (final r in repasDetail) r.repas.id: r},
      );

      expect(suggestions, isEmpty);
    });

    test('article déjà en liste couvrant partiellement -> suggestion du solde', () async {
      final riz = await creerProduit('Riz');
      final plat = await PlatRepository(db).create(
        nom: 'Riz',
        portionsDefaut: 1,
        ingredients: [
          IngredientInput(produitId: riz.id, quantite: 300, uniteId: 1),
        ],
      );
      await repasRepo.planifier(
        date: DateTime(2026, 9, 1),
        platId: plat.id,
        portions: 1,
      );
      final articleExistant = await articleRepo.ajouter(
        produitId: riz.id,
        quantite: 100,
        uniteId: 1,
      );

      final repasDetail = await repasRepo.watchPlanifiesDetail().first;
      final ingredients = <int, List<PlatIngredient>>{
        plat.id: await db.select(db.platIngredients).get(),
      };
      final produits = {
        for (final p in await db.select(db.produits).get()) p.id: p,
      };
      final u = await unites();
      final articlesActifs = [
        ArticleCourseDetail(
          article: articleExistant,
          produit: produits[riz.id]!,
          unite: u[1]!,
        ),
      ];

      final suggestions = calculerSuggestionsPlanification(
        repasPlanifies: repasDetail,
        stock: const [],
        ingredientsParPlat: ingredients,
        unitesParId: u,
        produitsParId: produits,
        articlesActifs: articlesActifs,
        repasParId: {for (final r in repasDetail) r.repas.id: r},
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.single.quantite, 200);
    });
  });

  group('calculerSuggestionsRupture', () {
    Future<void> consommerNFois(Produit produit, int n, {double quantite = 1000}) async {
      for (var i = 0; i < n; i++) {
        final instance = await frigoRepo.create(
          produitId: produit.id,
          zoneId: 1,
          quantite: quantite,
          uniteId: 3,
        );
        await frigoRepo.marquerConsomme(instance.id);
      }
    }

    test('seuil atteint + rupture réelle -> suggestion (dernière quantité)', () async {
      final lait = await creerProduit(
        'Lait',
        grandeur: TypeGrandeur.volume,
        uniteDefautId: 3,
      );
      await consommerNFois(lait, 3, quantite: 1000);

      final historique = await frigoRepo
          .watchHistoriqueRecent(DateTime.now().subtract(const Duration(days: 60)))
          .first;
      final u = await unites();

      final suggestions = calculerSuggestionsRupture(
        produitsActifs: [lait],
        stock: const [],
        historique: historique,
        unitesParId: u,
        produitIdsDejaEnListe: const {},
        seuilFrequence: 3,
        periodeJours: 60,
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.single.produitId, lait.id);
      expect(suggestions.single.quantite, 1000);
      expect(suggestions.single.origine, OrigineArticle.suggestionRupture);
    });

    test('sous le seuil -> aucune suggestion', () async {
      final lait = await creerProduit(
        'Lait',
        grandeur: TypeGrandeur.volume,
        uniteDefautId: 3,
      );
      await consommerNFois(lait, 2);

      final historique = await frigoRepo
          .watchHistoriqueRecent(DateTime.now().subtract(const Duration(days: 60)))
          .first;

      final suggestions = calculerSuggestionsRupture(
        produitsActifs: [lait],
        stock: const [],
        historique: historique,
        unitesParId: await unites(),
        produitIdsDejaEnListe: const {},
        seuilFrequence: 3,
        periodeJours: 60,
      );

      expect(suggestions, isEmpty);
    });

    test('encore en stock -> aucune suggestion malgré le seuil atteint', () async {
      final lait = await creerProduit(
        'Lait',
        grandeur: TypeGrandeur.volume,
        uniteDefautId: 3,
      );
      await consommerNFois(lait, 3);
      final enStock = await frigoRepo.create(
        produitId: lait.id,
        zoneId: 1,
        quantite: 500,
        uniteId: 3,
      );

      final historique = await frigoRepo
          .watchHistoriqueRecent(DateTime.now().subtract(const Duration(days: 60)))
          .first;
      final stock = await frigoRepo.watchEnStock().first;
      expect(stock.map((d) => d.instance.id), contains(enStock.id));

      final suggestions = calculerSuggestionsRupture(
        produitsActifs: [lait],
        stock: stock,
        historique: historique,
        unitesParId: await unites(),
        produitIdsDejaEnListe: const {},
        seuilFrequence: 3,
        periodeJours: 60,
      );

      expect(suggestions, isEmpty);
    });

    test('déjà dans la liste -> aucune suggestion', () async {
      final lait = await creerProduit(
        'Lait',
        grandeur: TypeGrandeur.volume,
        uniteDefautId: 3,
      );
      await consommerNFois(lait, 3);

      final historique = await frigoRepo
          .watchHistoriqueRecent(DateTime.now().subtract(const Duration(days: 60)))
          .first;

      final suggestions = calculerSuggestionsRupture(
        produitsActifs: [lait],
        stock: const [],
        historique: historique,
        unitesParId: await unites(),
        produitIdsDejaEnListe: {lait.id},
        seuilFrequence: 3,
        periodeJours: 60,
      );

      expect(suggestions, isEmpty);
    });
  });

  test('fusionnerSuggestions : la planification prime sur la rupture', () {
    const planif = SuggestionArticle(
      produitId: 1,
      produitNom: 'Lait',
      quantite: 500,
      uniteId: 3,
      uniteNom: 'millilitre',
      origine: OrigineArticle.suggestionPlanification,
      raison: 'Pour : Gâteau',
    );
    const rupture1 = SuggestionArticle(
      produitId: 1,
      produitNom: 'Lait',
      quantite: 1000,
      uniteId: 3,
      uniteNom: 'millilitre',
      origine: OrigineArticle.suggestionRupture,
      raison: 'Racheté souvent',
    );
    const rupture2 = SuggestionArticle(
      produitId: 2,
      produitNom: 'Farine',
      quantite: 1,
      uniteId: 2,
      uniteNom: 'kilogramme',
      origine: OrigineArticle.suggestionRupture,
      raison: 'Racheté souvent',
    );

    final fusion = fusionnerSuggestions(
      planification: [planif],
      rupture: [rupture1, rupture2],
    );

    expect(fusion, hasLength(2));
    expect(fusion.firstWhere((s) => s.produitId == 1).origine,
        OrigineArticle.suggestionPlanification);
    expect(fusion.firstWhere((s) => s.produitId == 2).origine,
        OrigineArticle.suggestionRupture);
  });
}
