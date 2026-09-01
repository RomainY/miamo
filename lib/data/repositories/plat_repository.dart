import 'package:drift/drift.dart';

import '../../shared/utils/exceptions.dart';
import '../database/app_database.dart';
import 'base_repository.dart';

/// Un ingrédient à écrire pour un plat (pas d'id : la liste complète d'un
/// plat est remplacée à chaque modification via [PlatRepository.remplacerIngredients]).
class IngredientInput {
  final int produitId;
  final double quantite;
  final int uniteId;

  const IngredientInput({
    required this.produitId,
    required this.quantite,
    required this.uniteId,
  });
}

/// Ingrédient enrichi des données produit/unité, pour l'affichage.
class IngredientDetail {
  final PlatIngredient ingredient;
  final Produit produit;
  final Unite unite;

  const IngredientDetail({
    required this.ingredient,
    required this.produit,
    required this.unite,
  });
}

/// Plats réutilisables : nom, ingrédients, temps de préparation, notes,
/// portions par défaut (cahier-des-charges.md §7.5).
class PlatRepository extends BaseRepository {
  const PlatRepository(super.db);

  Stream<List<Plat>> watchAll() {
    return (db.select(
      db.plats,
    )..orderBy([(t) => OrderingTerm.asc(t.nom)])).watch();
  }

  Future<Plat> getById(int id) {
    return (db.select(db.plats)..where((t) => t.id.equals(id))).getSingle();
  }

  Stream<List<IngredientDetail>> watchIngredients(int platId) {
    return _ingredientsQuery(platId).watch().map(_lireIngredients);
  }

  /// Lecture ponctuelle (non réactive), pour initialiser un formulaire
  /// d'édition sans se réabonner à chaque frappe.
  Future<List<IngredientDetail>> getIngredients(int platId) async {
    return _lireIngredients(await _ingredientsQuery(platId).get());
  }

  /// Tous les ingrédients de tous les plats, pour le calcul transverse de
  /// disponibilité des repas planifiés (regroupement par `platId` côté
  /// appelant).
  Stream<List<PlatIngredient>> watchTousIngredients() {
    return db.select(db.platIngredients).watch();
  }

  JoinedSelectStatement _ingredientsQuery(int platId) {
    return db.select(db.platIngredients).join([
      innerJoin(
        db.produits,
        db.produits.id.equalsExp(db.platIngredients.produitId),
      ),
      innerJoin(db.unites, db.unites.id.equalsExp(db.platIngredients.uniteId)),
    ])..where(db.platIngredients.platId.equals(platId));
  }

  List<IngredientDetail> _lireIngredients(List<TypedResult> rows) {
    return rows
        .map(
          (row) => IngredientDetail(
            ingredient: row.readTable(db.platIngredients),
            produit: row.readTable(db.produits),
            unite: row.readTable(db.unites),
          ),
        )
        .toList();
  }

  Future<Plat> create({
    required String nom,
    int? tempsPrepa,
    String? notes,
    required int portionsDefaut,
    List<IngredientInput> ingredients = const [],
  }) async {
    return db.transaction(() async {
      final id = await db
          .into(db.plats)
          .insert(
            PlatsCompanion.insert(
              nom: nom,
              tempsPrepa: Value(tempsPrepa),
              notes: Value(notes),
              portionsDefaut: Value(portionsDefaut),
            ),
          );
      if (ingredients.isNotEmpty) {
        await _ecrireIngredients(id, ingredients);
      }
      return (db.select(db.plats)..where((t) => t.id.equals(id))).getSingle();
    });
  }

  Future<Plat> update(
    int id, {
    String? nom,
    int? tempsPrepa,
    String? notes,
    int? portionsDefaut,
  }) async {
    await (db.update(db.plats)..where((t) => t.id.equals(id))).write(
      PlatsCompanion(
        nom: nom == null ? const Value.absent() : Value(nom),
        tempsPrepa: tempsPrepa == null
            ? const Value.absent()
            : Value(tempsPrepa),
        notes: notes == null ? const Value.absent() : Value(notes),
        portionsDefaut: portionsDefaut == null
            ? const Value.absent()
            : Value(portionsDefaut),
      ),
    );
    return getById(id);
  }

  /// Remplace la liste complète des ingrédients d'un plat.
  Future<void> remplacerIngredients(
    int platId,
    List<IngredientInput> ingredients,
  ) async {
    await db.transaction(() async {
      await (db.delete(
        db.platIngredients,
      )..where((t) => t.platId.equals(platId))).go();
      await _ecrireIngredients(platId, ingredients);
    });
  }

  /// Lève [ReferenceActiveException] si le plat est encore utilisé par des
  /// repas planifiés (pas de suppression en cascade des repas, non
  /// spécifiée par le cahier des charges).
  Future<void> delete(int id) async {
    final repasLies = await (db.select(
      db.repasPlanifies,
    )..where((t) => t.platId.equals(id))).get();
    if (repasLies.isNotEmpty) {
      throw const ReferenceActiveException(
        'Ce plat est utilisé par des repas planifiés : '
        'annulez ou modifiez ces repas avant de le supprimer.',
      );
    }

    await db.transaction(() async {
      await (db.delete(
        db.platIngredients,
      )..where((t) => t.platId.equals(id))).go();
      await (db.delete(db.plats)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> _ecrireIngredients(
    int platId,
    List<IngredientInput> ingredients,
  ) async {
    await db.batch((batch) {
      batch.insertAll(
        db.platIngredients,
        ingredients
            .map(
              (i) => PlatIngredientsCompanion.insert(
                platId: platId,
                produitId: i.produitId,
                quantite: i.quantite,
                uniteId: i.uniteId,
              ),
            )
            .toList(),
      );
    });
  }
}
