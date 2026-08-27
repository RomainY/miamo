import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';
import 'base_repository.dart';

/// Repas planifié enrichi du Plat ou Produit isolé associé (exactement l'un
/// des deux), pour l'affichage sans requête supplémentaire par ligne.
class RepasPlanifieDetail {
  final RepasPlanifie repas;
  final Plat? plat;
  final Produit? produit;

  const RepasPlanifieDetail({required this.repas, this.plat, this.produit});

  String get titre => plat?.nom ?? produit?.nom ?? '?';
}

/// Planification de repas — Plat ou produit isolé (cahier-des-charges.md
/// §7.5). Le décompte du frigo ne se fait qu'au passage à `fait`.
///
/// ⚠️ Hypothèse d'implémentation (non explicitement tranchée par le cahier
/// des charges) : pour un repas "produit isolé", `portions` est interprété
/// directement comme la quantité consommée, dans l'unité par défaut du
/// produit. Le décompte est réalisé au mieux (FIFO par date de péremption
/// puis date d'ajout) : un stock insuffisant ne bloque pas le passage à
/// "fait", il se contente de vider ce qui est disponible. À valider/ajuster
/// une fois le comportement observé en usage réel.
class RepasPlanifieRepository extends BaseRepository {
  const RepasPlanifieRepository(super.db);

  Stream<List<RepasPlanifie>> watchByDateRange(DateTime debut, DateTime fin) {
    return (db.select(db.repasPlanifies)
          ..where((t) => t.date.isBetweenValues(debut, fin))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  Stream<List<RepasPlanifie>> watchProchains({DateTime? apartirDe}) {
    return (db.select(db.repasPlanifies)
          ..where(
            (t) => t.date.isBiggerOrEqualValue(apartirDe ?? DateTime.now()),
          )
          ..where((t) => t.statut.equalsValue(StatutRepas.planifie))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  Stream<List<RepasPlanifieDetail>> watchByDateRangeDetail(
    DateTime debut,
    DateTime fin,
  ) {
    final query =
        db.select(db.repasPlanifies).join([
            leftOuterJoin(
              db.plats,
              db.plats.id.equalsExp(db.repasPlanifies.platId),
            ),
            leftOuterJoin(
              db.produits,
              db.produits.id.equalsExp(db.repasPlanifies.produitId),
            ),
          ])
          ..where(db.repasPlanifies.date.isBetweenValues(debut, fin))
          ..orderBy([OrderingTerm.asc(db.repasPlanifies.date)]);
    return _watchDetail(query);
  }

  Stream<List<RepasPlanifieDetail>> watchProchainsDetail({
    DateTime? apartirDe,
  }) {
    final query =
        db.select(db.repasPlanifies).join([
            leftOuterJoin(
              db.plats,
              db.plats.id.equalsExp(db.repasPlanifies.platId),
            ),
            leftOuterJoin(
              db.produits,
              db.produits.id.equalsExp(db.repasPlanifies.produitId),
            ),
          ])
          ..where(
            db.repasPlanifies.date.isBiggerOrEqualValue(
              apartirDe ?? DateTime.now(),
            ),
          )
          ..where(db.repasPlanifies.statut.equalsValue(StatutRepas.planifie))
          ..orderBy([OrderingTerm.asc(db.repasPlanifies.date)]);
    return _watchDetail(query);
  }

  Stream<List<RepasPlanifieDetail>> _watchDetail(JoinedSelectStatement query) {
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => RepasPlanifieDetail(
              repas: row.readTable(db.repasPlanifies),
              plat: row.readTableOrNull(db.plats),
              produit: row.readTableOrNull(db.produits),
            ),
          )
          .toList(),
    );
  }

  Future<RepasPlanifie> getById(int id) {
    return (db.select(
      db.repasPlanifies,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  /// Planifie un Plat ou un produit isolé (exactement l'un des deux) sur une
  /// date, avec un nombre de portions ajustable.
  Future<RepasPlanifie> planifier({
    required DateTime date,
    int? platId,
    int? produitId,
    required int portions,
  }) async {
    final unSeulChoisi = (platId != null) ^ (produitId != null);
    if (!unSeulChoisi) {
      throw ArgumentError(
        'Un repas planifié référence soit un plat, soit un produit isolé '
        '(exclusivement).',
      );
    }

    final id = await db
        .into(db.repasPlanifies)
        .insert(
          RepasPlanifiesCompanion.insert(
            date: date,
            platId: Value(platId),
            produitId: Value(produitId),
            portions: portions,
          ),
        );
    return getById(id);
  }

  Future<void> ajusterPortions(int id, int portions) async {
    await (db.update(db.repasPlanifies)..where((t) => t.id.equals(id))).write(
      RepasPlanifiesCompanion(portions: Value(portions)),
    );
  }

  Future<void> annuler(int id) => _changerStatut(id, StatutRepas.annule);

  /// Marque le repas "fait" et décompte le frigo (documentation-technique.md
  /// §3 "Décompte réel du frigo"). Ne peut être appelé que depuis le statut
  /// `planifie`.
  Future<void> marquerFait(int id) async {
    await db.transaction(() async {
      final repas = await getById(id);
      if (repas.statut != StatutRepas.planifie) {
        throw StateError(
          'Seul un repas au statut "planifié" peut être marqué "fait".',
        );
      }

      if (repas.platId != null) {
        final plat = await (db.select(
          db.plats,
        )..where((t) => t.id.equals(repas.platId!))).getSingle();
        final ratio = plat.portionsDefaut == 0
            ? 1.0
            : repas.portions / plat.portionsDefaut;
        final ingredients = await (db.select(
          db.platIngredients,
        )..where((t) => t.platId.equals(plat.id))).get();
        for (final ingredient in ingredients) {
          await _decrementerStock(
            produitId: ingredient.produitId,
            quantiteNecessaire: ingredient.quantite * ratio,
            uniteBesoinId: ingredient.uniteId,
          );
        }
      } else if (repas.produitId != null) {
        final produit = await (db.select(
          db.produits,
        )..where((t) => t.id.equals(repas.produitId!))).getSingle();
        await _decrementerStock(
          produitId: produit.id,
          quantiteNecessaire: repas.portions.toDouble(),
          uniteBesoinId: produit.uniteDefautId,
        );
      }

      await (db.update(db.repasPlanifies)..where((t) => t.id.equals(id))).write(
        const RepasPlanifiesCompanion(statut: Value(StatutRepas.fait)),
      );
    });
  }

  /// Décrémente le stock en_stock d'un produit, en base de conversion de
  /// grandeur, FIFO par urgence de péremption puis date d'ajout. Best-effort :
  /// un stock insuffisant n'est pas signalé comme erreur (cf. note de tête
  /// de fichier).
  Future<void> _decrementerStock({
    required int produitId,
    required double quantiteNecessaire,
    required int uniteBesoinId,
  }) async {
    if (quantiteNecessaire <= 0) return;

    final uniteBesoin = await (db.select(
      db.unites,
    )..where((t) => t.id.equals(uniteBesoinId))).getSingle();
    var quantiteBaseRestante = quantiteNecessaire * uniteBesoin.facteurVersBase;

    final lignes =
        await (db.select(db.produitsFrigo)
              ..where((t) => t.produitId.equals(produitId))
              ..where((t) => t.statut.equalsValue(StatutProduitFrigo.enStock))
              ..orderBy([
                (t) => OrderingTerm(expression: t.datePeremption.isNull()),
                (t) => OrderingTerm.asc(t.datePeremption),
                (t) => OrderingTerm.asc(t.dateAjout),
              ]))
            .get();

    for (final ligne in lignes) {
      if (quantiteBaseRestante <= 0) break;

      final uniteLigne = await (db.select(
        db.unites,
      )..where((t) => t.id.equals(ligne.uniteId))).getSingle();
      if (uniteLigne.typeGrandeur != uniteBesoin.typeGrandeur) {
        continue;
      }

      final ligneBase = ligne.quantite * uniteLigne.facteurVersBase;
      if (ligneBase <= quantiteBaseRestante) {
        await (db.update(
          db.produitsFrigo,
        )..where((t) => t.id.equals(ligne.id))).write(
          ProduitsFrigoCompanion(
            statut: Value(StatutProduitFrigo.consomme),
            dateStatut: Value(DateTime.now()),
          ),
        );
        quantiteBaseRestante -= ligneBase;
      } else {
        final quantiteLigneRestante =
            (ligneBase - quantiteBaseRestante) / uniteLigne.facteurVersBase;
        await (db.update(
          db.produitsFrigo,
        )..where((t) => t.id.equals(ligne.id))).write(
          ProduitsFrigoCompanion(quantite: Value(quantiteLigneRestante)),
        );
        quantiteBaseRestante = 0;
      }
    }
  }

  Future<void> _changerStatut(int id, StatutRepas statut) async {
    await (db.update(db.repasPlanifies)..where((t) => t.id.equals(id))).write(
      RepasPlanifiesCompanion(statut: Value(statut)),
    );
  }
}
