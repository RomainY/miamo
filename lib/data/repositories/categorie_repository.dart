import 'package:drift/drift.dart';

import '../../shared/utils/exceptions.dart';
import '../database/app_database.dart';
import 'base_repository.dart';

/// CRUD complet sur le catalogue des catégories (cahier-des-charges.md §7.1).
///
/// La catégorie `estParDefaut` ("Non classé", seedée au premier lancement)
/// est la cible de réaffectation automatique des produits d'une catégorie
/// supprimée ; elle est modifiable mais jamais supprimable.
class CategorieRepository extends BaseRepository {
  const CategorieRepository(super.db);

  Stream<List<Categorie>> watchAll() {
    return (db.select(db.categories)
          ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
        .watch();
  }

  Future<List<Categorie>> getAll() {
    return (db.select(db.categories)
          ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
        .get();
  }

  Future<Categorie> getDefault() {
    return (db.select(
      db.categories,
    )..where((t) => t.estParDefaut.equals(true))).getSingle();
  }

  Future<Categorie> create({required String nom, String? icone}) async {
    await _verifierNomLibre(nom);
    final id = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            nom: nom,
            icone: icone == null ? const Value.absent() : Value(icone),
          ),
        );
    return _getById(id);
  }

  Future<Categorie> update(int id, {String? nom, String? icone}) async {
    if (nom != null) {
      await _verifierNomLibre(nom, exclureId: id);
    }
    await (db.update(
      db.categories,
    )..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        nom: nom == null ? const Value.absent() : Value(nom),
        icone: icone == null ? const Value.absent() : Value(icone),
      ),
    );
    return _getById(id);
  }

  /// Supprime une catégorie et réaffecte ses produits vers "Non classé".
  /// Lève [ElementProtegeException] pour la catégorie par défaut elle-même.
  Future<void> delete(int id) async {
    final categorie = await _getById(id);
    if (categorie.estParDefaut) {
      throw const ElementProtegeException(
        'La catégorie par défaut ne peut pas être supprimée.',
      );
    }

    await db.transaction(() async {
      final defaut = await getDefault();
      await (db.update(db.produits)..where(
            (t) => t.categorieId.equals(id),
          ))
          .write(ProduitsCompanion(categorieId: Value(defaut.id)));
      await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<Categorie> _getById(int id) {
    return (db.select(
      db.categories,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> _verifierNomLibre(String nom, {int? exclureId}) async {
    final query = db.select(db.categories)..where((t) => t.nom.equals(nom));
    final existant = await query.getSingleOrNull();
    if (existant != null && existant.id != exclureId) {
      throw const DuplicateNameException('Cette catégorie existe déjà.');
    }
  }
}
