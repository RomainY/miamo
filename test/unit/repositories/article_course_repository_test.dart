import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/article_course_repository.dart';
import 'package:miamo/data/repositories/produit_repository.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late ArticleCourseRepository repo;
  late int produitId;

  setUp(() async {
    db = createTestDatabase();
    repo = ArticleCourseRepository(db);
    final produit = await ProduitRepository(db).create(
      nom: 'Lait',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.volume,
      uniteDefautId: 3, // millilitre
    );
    produitId = produit.id;
  });

  tearDown(() => db.close());

  test(
    'ajouterManuel crée un article origine=manuel, statut=a_acheter',
    () async {
      final article = await repo.ajouterManuel(
        produitId: produitId,
        quantite: 1000,
        uniteId: 3,
      );
      expect(article.origine, OrigineArticle.manuel);
      expect(article.statut, StatutArticle.aAcheter);
    },
  );

  test('marquerAchete change le statut', () async {
    final article = await repo.ajouterManuel(
      produitId: produitId,
      quantite: 1000,
      uniteId: 3,
    );
    await repo.marquerAchete(article.id);
    final relu = await repo.getById(article.id);
    expect(relu.statut, StatutArticle.achete);
  });

  test(
    'renvoyerVersFrigo crée une instance en zone et conserve l\'article',
    () async {
      final article = await repo.ajouterManuel(
        produitId: produitId,
        quantite: 1000,
        uniteId: 3,
      );

      final instance = await repo.renvoyerVersFrigo(
        articleId: article.id,
        zoneId: 1,
        datePeremption: DateTime(2026, 9, 1),
      );

      expect(instance.produitId, produitId);
      expect(instance.quantite, 1000);
      final articleApres = await repo.getById(article.id);
      expect(articleApres.statut, StatutArticle.achete);
    },
  );
}
