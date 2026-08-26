import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';
import 'base_repository.dart';

/// Instance physique enrichie des données produit/unité/zone nécessaires à
/// l'affichage (nom, urgence de péremption...) sans requête supplémentaire
/// par ligne côté UI.
class InstanceFrigoDetail {
  final ProduitFrigo instance;
  final Produit produit;
  final Unite unite;
  final Zone zone;

  const InstanceFrigoDetail({
    required this.instance,
    required this.produit,
    required this.unite,
    required this.zone,
  });
}

/// Instances physiques stockées en zone (cahier-des-charges.md §7.4).
class ProduitFrigoRepository extends BaseRepository {
  const ProduitFrigoRepository(super.db);

  /// Liste des instances en stock, triées par urgence de péremption
  /// (péremption la plus proche en premier, sans date en dernier),
  /// filtrable par zone et/ou catégorie.
  Stream<List<InstanceFrigoDetail>> watchEnStock({
    int? zoneId,
    int? categorieId,
  }) {
    final query =
        db.select(db.produitsFrigo).join([
            innerJoin(
              db.produits,
              db.produits.id.equalsExp(db.produitsFrigo.produitId),
            ),
            innerJoin(
              db.unites,
              db.unites.id.equalsExp(db.produitsFrigo.uniteId),
            ),
            innerJoin(
              db.zones,
              db.zones.id.equalsExp(db.produitsFrigo.zoneId),
            ),
          ])
          ..where(
            db.produitsFrigo.statut.equalsValue(StatutProduitFrigo.enStock),
          )
          ..orderBy([
            OrderingTerm(expression: db.produitsFrigo.datePeremption.isNull()),
            OrderingTerm.asc(db.produitsFrigo.datePeremption),
          ]);
    if (zoneId != null) {
      query.where(db.produitsFrigo.zoneId.equals(zoneId));
    }
    if (categorieId != null) {
      query.where(db.produits.categorieId.equals(categorieId));
    }

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => InstanceFrigoDetail(
              instance: row.readTable(db.produitsFrigo),
              produit: row.readTable(db.produits),
              unite: row.readTable(db.unites),
              zone: row.readTable(db.zones),
            ),
          )
          .toList(),
    );
  }

  Future<ProduitFrigo> getById(int id) {
    return (db.select(
      db.produitsFrigo,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  /// Ajoute une instance en zone (chemin A ou B de
  /// documentation-technique.md §3 "Flux d'ajout d'un ProduitFrigo") et
  /// remonte le produit dans l'autocomplétion.
  Future<ProduitFrigo> create({
    required int produitId,
    required int zoneId,
    required double quantite,
    required int uniteId,
    DateTime? dateAjout,
    DateTime? datePeremption,
  }) async {
    return db.transaction(() async {
      final id = await db
          .into(db.produitsFrigo)
          .insert(
            ProduitsFrigoCompanion.insert(
              produitId: produitId,
              zoneId: zoneId,
              quantite: quantite,
              uniteId: uniteId,
              dateAjout: dateAjout ?? DateTime.now(),
              datePeremption: Value(datePeremption),
            ),
          );
      await (db.update(
        db.produits,
      )..where((t) => t.id.equals(produitId))).write(
        ProduitsCompanion(dateDerniereUtilisation: Value(DateTime.now())),
      );
      return (db.select(
        db.produitsFrigo,
      )..where((t) => t.id.equals(id))).getSingle();
    });
  }

  /// [datePeremption] utilise `Value` pour distinguer "ne pas modifier"
  /// (`Value.absent()`, la valeur par défaut) de "effacer la date" (passer
  /// explicitement `Value(null)`) — un simple `DateTime?` ne le permettrait
  /// pas, `null` étant ambigu entre les deux intentions.
  Future<ProduitFrigo> update(
    int id, {
    double? quantite,
    int? zoneId,
    int? uniteId,
    Value<DateTime?> datePeremption = const Value.absent(),
  }) async {
    await (db.update(db.produitsFrigo)..where((t) => t.id.equals(id))).write(
      ProduitsFrigoCompanion(
        quantite: quantite == null ? const Value.absent() : Value(quantite),
        zoneId: zoneId == null ? const Value.absent() : Value(zoneId),
        uniteId: uniteId == null ? const Value.absent() : Value(uniteId),
        datePeremption: datePeremption,
      ),
    );
    return getById(id);
  }

  Future<void> marquerConsomme(int id) => _marquerStatut(
    id,
    StatutProduitFrigo.consomme,
  );

  Future<void> marquerJete(int id) => _marquerStatut(id, StatutProduitFrigo.jete);

  /// Suppression d'une ligne (correction d'erreur de saisie) : contrairement
  /// à consommé/jeté, n'alimente pas les statistiques anti-gaspi.
  Future<void> supprimerInstance(int id) async {
    await (db.delete(db.produitsFrigo)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _marquerStatut(int id, StatutProduitFrigo statut) async {
    await (db.update(db.produitsFrigo)..where((t) => t.id.equals(id))).write(
      ProduitsFrigoCompanion(
        statut: Value(statut),
        dateStatut: Value(DateTime.now()),
      ),
    );
  }
}
