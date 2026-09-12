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

/// Une occurrence `consomme`/`jete` récente d'un produit, brique de
/// l'heuristique de suggestion "rachat fréquent"
/// (`Docs/poc-liste-courses-auto.md` §3.2). Les suppressions directes
/// (`supprimerInstance`) n'en font jamais partie : `dateStatut` n'est posée
/// que par `marquerConsomme`/`marquerJete`.
class HistoriqueStatutProduit {
  final int produitId;
  final StatutProduitFrigo statut;
  final DateTime dateStatut;
  final double quantite;
  final int uniteId;

  const HistoriqueStatutProduit({
    required this.produitId,
    required this.statut,
    required this.dateStatut,
    required this.quantite,
    required this.uniteId,
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
            innerJoin(db.zones, db.zones.id.equalsExp(db.produitsFrigo.zoneId)),
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

  /// Historique `consomme`/`jete` depuis [depuis] (bornes incluses), toutes
  /// zones/produits confondus — brique brute pour l'heuristique de
  /// suggestion "rachat fréquent" (agrégation par produit faite côté domaine,
  /// pas ici). Voir [HistoriqueStatutProduit].
  Stream<List<HistoriqueStatutProduit>> watchHistoriqueRecent(
    DateTime depuis,
  ) {
    final query = db.select(db.produitsFrigo)
      ..where(
        (t) =>
            t.dateStatut.isBiggerOrEqualValue(depuis) &
            (t.statut.equalsValue(StatutProduitFrigo.consomme) |
                t.statut.equalsValue(StatutProduitFrigo.jete)),
      );
    return query.watch().map(
      (lignes) => [
        for (final l in lignes)
          HistoriqueStatutProduit(
            produitId: l.produitId,
            statut: l.statut,
            dateStatut: l.dateStatut!,
            quantite: l.quantite,
            uniteId: l.uniteId,
          ),
      ],
    );
  }

  Future<ProduitFrigo> getById(int id) {
    return (db.select(
      db.produitsFrigo,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  /// Dernière instance ajoutée pour ce produit (tous statuts confondus), pour
  /// préremplir quantité/unité/durée de conservation typique lors d'un
  /// nouvel ajout (scan ou sélection dans le catalogue). `null` si le produit
  /// n'a jamais été ajouté.
  Future<ProduitFrigo?> getDerniereInstance(int produitId) {
    return (db.select(db.produitsFrigo)
          ..where((t) => t.produitId.equals(produitId))
          ..orderBy([(t) => OrderingTerm.desc(t.dateAjout)])
          ..limit(1))
        .getSingleOrNull();
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

  Future<void> marquerConsomme(int id) =>
      _marquerStatut(id, StatutProduitFrigo.consomme);

  Future<void> marquerJete(int id) =>
      _marquerStatut(id, StatutProduitFrigo.jete);

  /// Marque le début de consommation (ex. produit ouvert) — alimente le
  /// badge "ouvert depuis" et la notification d'approche de limite de
  /// consommation (cf. `dateOuverture` dans `tables.dart`).
  Future<void> marquerEntame(int id) async {
    await (db.update(db.produitsFrigo)..where((t) => t.id.equals(id))).write(
      ProduitsFrigoCompanion(dateOuverture: Value(DateTime.now())),
    );
  }

  /// Annule le marquage "entamé" (erreur de saisie) — n'affecte ni le statut
  /// ni la date de péremption, seulement le suivi d'ouverture.
  Future<void> annulerEntame(int id) async {
    await (db.update(db.produitsFrigo)..where((t) => t.id.equals(id))).write(
      const ProduitsFrigoCompanion(dateOuverture: Value(null)),
    );
  }

  /// Retire 1 du stock d'une instance comptée à l'unité (ex. « yaourts x6 ») —
  /// raccourci pour ne pas rouvrir "Modifier" à chaque fois, une pression =
  /// -1 (demande du 11/09/2026). Si la quantité atteint 0, l'instance passe
  /// automatiquement à `consomme` (comme `marquerConsomme`, alimente les
  /// statistiques anti-gaspi) plutôt que de laisser une ligne à 0 en stock.
  Future<void> retirerUn(int id) async {
    await db.transaction(() async {
      final instance = await getById(id);
      final restant = instance.quantite - 1;
      if (restant <= 0) {
        await (db.update(db.produitsFrigo)..where((t) => t.id.equals(id)))
            .write(
              ProduitsFrigoCompanion(
                quantite: const Value(0),
                statut: const Value(StatutProduitFrigo.consomme),
                dateStatut: Value(DateTime.now()),
              ),
            );
      } else {
        await (db.update(db.produitsFrigo)..where((t) => t.id.equals(id)))
            .write(ProduitsFrigoCompanion(quantite: Value(restant)));
      }
    });
  }

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
