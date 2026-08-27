import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';
import 'base_repository.dart';

/// Article de courses enrichi du produit/unité pour l'affichage.
class ArticleCourseDetail {
  final ArticleCourse article;
  final Produit produit;
  final Unite unite;

  const ArticleCourseDetail({
    required this.article,
    required this.produit,
    required this.unite,
  });
}

/// Liste de courses — MVP v1 : ajout manuel uniquement
/// (cahier-des-charges.md §7.6 / §3.3).
class ArticleCourseRepository extends BaseRepository {
  const ArticleCourseRepository(super.db);

  Stream<List<ArticleCourseDetail>> watchAll({StatutArticle? statut}) {
    final query = db.select(db.articlesCourse).join([
      innerJoin(
        db.produits,
        db.produits.id.equalsExp(db.articlesCourse.produitId),
      ),
      innerJoin(db.unites, db.unites.id.equalsExp(db.articlesCourse.uniteId)),
    ]);
    if (statut != null) {
      query.where(db.articlesCourse.statut.equalsValue(statut));
    }
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ArticleCourseDetail(
              article: row.readTable(db.articlesCourse),
              produit: row.readTable(db.produits),
              unite: row.readTable(db.unites),
            ),
          )
          .toList(),
    );
  }

  Future<ArticleCourse> getById(int id) {
    return (db.select(
      db.articlesCourse,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  /// MVP v1 : seule l'origine `manuel` est exposée
  /// (documentation-technique.md §2 "ArticleCourse").
  Future<ArticleCourse> ajouterManuel({
    required int produitId,
    required double quantite,
    required int uniteId,
  }) async {
    final id = await db
        .into(db.articlesCourse)
        .insert(
          ArticlesCourseCompanion.insert(
            produitId: produitId,
            quantite: quantite,
            uniteId: uniteId,
          ),
        );
    return getById(id);
  }

  Future<void> marquerAchete(int id) async {
    await (db.update(db.articlesCourse)..where((t) => t.id.equals(id))).write(
      const ArticlesCourseCompanion(statut: Value(StatutArticle.achete)),
    );
  }

  Future<void> supprimer(int id) async {
    await (db.delete(db.articlesCourse)..where((t) => t.id.equals(id))).go();
  }

  /// Renvoie un article acheté vers le frigo, en réutilisant le flux d'ajout
  /// d'une instance en zone (cahier-des-charges.md §3.3). L'article reste en
  /// base (statut `achete`) pour l'historique.
  Future<ProduitFrigo> renvoyerVersFrigo({
    required int articleId,
    required int zoneId,
    DateTime? datePeremption,
  }) async {
    return db.transaction(() async {
      final article = await getById(articleId);

      final instanceId = await db
          .into(db.produitsFrigo)
          .insert(
            ProduitsFrigoCompanion.insert(
              produitId: article.produitId,
              zoneId: zoneId,
              quantite: article.quantite,
              uniteId: article.uniteId,
              dateAjout: DateTime.now(),
              datePeremption: Value(datePeremption),
            ),
          );

      await (db.update(
        db.articlesCourse,
      )..where((t) => t.id.equals(articleId))).write(
        const ArticlesCourseCompanion(statut: Value(StatutArticle.achete)),
      );
      await (db.update(
        db.produits,
      )..where((t) => t.id.equals(article.produitId))).write(
        ProduitsCompanion(dateDerniereUtilisation: Value(DateTime.now())),
      );

      return (db.select(
        db.produitsFrigo,
      )..where((t) => t.id.equals(instanceId))).getSingle();
    });
  }
}
