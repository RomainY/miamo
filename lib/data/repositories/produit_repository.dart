import 'package:drift/drift.dart';

import '../../shared/utils/exceptions.dart';
import '../database/app_database.dart';
import '../database/tables.dart';
import 'base_repository.dart';

/// Récapitulatif des éléments impactés par la suppression définitive d'un
/// produit archivé, à présenter à l'utilisateur avant confirmation
/// (documentation-technique.md §3 "Cycle de vie d'un Produit du catalogue").
class CascadeSuppressionProduit {
  final int instancesFrigo;
  final int ingredientsPlat;
  final int articlesCourse;
  final int repasPlanifies;

  const CascadeSuppressionProduit({
    required this.instancesFrigo,
    required this.ingredientsPlat,
    required this.articlesCourse,
    required this.repasPlanifies,
  });

  bool get estVide =>
      instancesFrigo == 0 &&
      ingredientsPlat == 0 &&
      articlesCourse == 0 &&
      repasPlanifies == 0;
}

/// Gestion du catalogue de produits, réutilisable dans le temps et distinct
/// des instances physiques stockées (cahier-des-charges.md §7.3).
class ProduitRepository extends BaseRepository {
  const ProduitRepository(super.db);

  /// Autocomplétion : produits actifs, triés par usage récent, filtrables
  /// par catégorie.
  Stream<List<Produit>> watchActifs({int? categorieId}) {
    final query = db.select(db.produits)
      ..where((t) => t.statut.equalsValue(StatutProduit.actif));
    if (categorieId != null) {
      query.where((t) => t.categorieId.equals(categorieId));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.dateDerniereUtilisation.isNull()),
      (t) => OrderingTerm.desc(t.dateDerniereUtilisation),
    ]);
    return query.watch();
  }

  /// Catalogue complet (actifs + archivés), pour l'écran de gestion.
  Stream<List<Produit>> watchAll({int? categorieId}) {
    final query = db.select(db.produits)
      ..orderBy([(t) => OrderingTerm.asc(t.nom)]);
    if (categorieId != null) {
      query.where((t) => t.categorieId.equals(categorieId));
    }
    return query.watch();
  }

  Future<Produit> getById(int id) {
    return (db.select(db.produits)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Crée un produit (chemin B : nouveau produit créé à la volée, ou écran
  /// de gestion dédié). `typeGrandeur` est fixé définitivement à la création.
  Future<Produit> create({
    required String nom,
    required int categorieId,
    required TypeGrandeur typeGrandeur,
    required int uniteDefautId,
  }) async {
    await _verifierNomLibre(nom);
    await _verifierCoherenceUnite(uniteDefautId, typeGrandeur);

    final id = await db
        .into(db.produits)
        .insert(
          ProduitsCompanion.insert(
            nom: nom,
            categorieId: categorieId,
            typeGrandeur: typeGrandeur,
            uniteDefautId: uniteDefautId,
            dateDerniereUtilisation: Value(DateTime.now()),
          ),
        );
    return getById(id);
  }

  /// `typeGrandeur` n'est volontairement pas modifiable ici (fixe après
  /// création, cf. documentation-technique.md §2 "Produit").
  Future<Produit> update(
    int id, {
    String? nom,
    int? categorieId,
    int? uniteDefautId,
  }) async {
    if (nom != null) {
      await _verifierNomLibre(nom, exclureId: id);
    }
    if (uniteDefautId != null) {
      final produit = await getById(id);
      await _verifierCoherenceUnite(uniteDefautId, produit.typeGrandeur);
    }
    await (db.update(db.produits)..where((t) => t.id.equals(id))).write(
      ProduitsCompanion(
        nom: nom == null ? const Value.absent() : Value(nom),
        categorieId: categorieId == null
            ? const Value.absent()
            : Value(categorieId),
        uniteDefautId: uniteDefautId == null
            ? const Value.absent()
            : Value(uniteDefautId),
      ),
    );
    return getById(id);
  }

  /// À appeler lorsqu'un produit existant est sélectionné (chemin A) pour
  /// remonter dans l'autocomplétion.
  Future<void> marquerUtilise(int id) async {
    await (db.update(db.produits)..where((t) => t.id.equals(id))).write(
      ProduitsCompanion(dateDerniereUtilisation: Value(DateTime.now())),
    );
  }

  Future<void> archiver(int id) async {
    await (db.update(db.produits)..where((t) => t.id.equals(id))).write(
      ProduitsCompanion(statut: Value(StatutProduit.archive)),
    );
  }

  Future<void> desarchiver(int id) async {
    await (db.update(db.produits)..where((t) => t.id.equals(id))).write(
      ProduitsCompanion(statut: Value(StatutProduit.actif)),
    );
  }

  /// Compte les éléments qui seraient supprimés par [supprimerDefinitivement],
  /// à afficher à l'utilisateur avant confirmation.
  Future<CascadeSuppressionProduit> previewSuppressionCascade(
    int produitId,
  ) async {
    final instancesFrigo =
        await (db.selectOnly(db.produitsFrigo)
              ..addColumns([db.produitsFrigo.id.count()])
              ..where(db.produitsFrigo.produitId.equals(produitId)))
            .map((row) => row.read(db.produitsFrigo.id.count()) ?? 0)
            .getSingle();
    final ingredientsPlat =
        await (db.selectOnly(db.platIngredients)
              ..addColumns([db.platIngredients.id.count()])
              ..where(db.platIngredients.produitId.equals(produitId)))
            .map((row) => row.read(db.platIngredients.id.count()) ?? 0)
            .getSingle();
    final articlesCourse =
        await (db.selectOnly(db.articlesCourse)
              ..addColumns([db.articlesCourse.id.count()])
              ..where(db.articlesCourse.produitId.equals(produitId)))
            .map((row) => row.read(db.articlesCourse.id.count()) ?? 0)
            .getSingle();
    final repasPlanifies =
        await (db.selectOnly(db.repasPlanifies)
              ..addColumns([db.repasPlanifies.id.count()])
              ..where(db.repasPlanifies.produitId.equals(produitId)))
            .map((row) => row.read(db.repasPlanifies.id.count()) ?? 0)
            .getSingle();

    return CascadeSuppressionProduit(
      instancesFrigo: instancesFrigo,
      ingredientsPlat: ingredientsPlat,
      articlesCourse: articlesCourse,
      repasPlanifies: repasPlanifies,
    );
  }

  /// Suppression définitive, possible uniquement depuis le statut `archive`.
  /// Supprime en cascade instances, ingrédients de plats, articles de
  /// courses et repas planifiés "produit isolé" liés à ce produit
  /// (documentation-technique.md §3 "Cycle de vie d'un Produit du catalogue").
  Future<void> supprimerDefinitivement(int produitId) async {
    final produit = await getById(produitId);
    if (produit.statut != StatutProduit.archive) {
      throw const ProduitNonArchiveException(
        'Seul un produit archivé peut être supprimé définitivement.',
      );
    }

    await db.transaction(() async {
      await (db.delete(
        db.produitsFrigo,
      )..where((t) => t.produitId.equals(produitId))).go();
      await (db.delete(
        db.platIngredients,
      )..where((t) => t.produitId.equals(produitId))).go();
      await (db.delete(
        db.articlesCourse,
      )..where((t) => t.produitId.equals(produitId))).go();
      await (db.delete(
        db.repasPlanifies,
      )..where((t) => t.produitId.equals(produitId))).go();
      await (db.delete(db.produits)..where((t) => t.id.equals(produitId))).go();
    });
  }

  Future<void> _verifierNomLibre(String nom, {int? exclureId}) async {
    final query = db.select(db.produits)..where((t) => t.nom.equals(nom));
    final existant = await query.getSingleOrNull();
    if (existant != null && existant.id != exclureId) {
      throw const DuplicateNameException('Ce produit existe déjà.');
    }
  }

  Future<void> _verifierCoherenceUnite(
    int uniteId,
    TypeGrandeur typeGrandeur,
  ) async {
    final unite = await (db.select(
      db.unites,
    )..where((t) => t.id.equals(uniteId))).getSingleOrNull();
    if (unite == null) {
      throw const EntiteIntrouvableException("Cette unité n'existe pas.");
    }
    if (unite.typeGrandeur != typeGrandeur) {
      throw ArgumentError(
        "L'unité choisie (${unite.nom}) ne correspond pas au type de "
        'grandeur du produit (${typeGrandeur.name}).',
      );
    }
  }
}
