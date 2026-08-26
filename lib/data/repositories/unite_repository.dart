import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';
import 'base_repository.dart';

/// Accès en lecture au référentiel d'unités (seedé au premier lancement,
/// cf. documentation-technique.md §2 "Unite"). Aucune gestion CRUD dédiée
/// n'est demandée par le cahier des charges pour cette entité en MVP v1.
class UniteRepository extends BaseRepository {
  const UniteRepository(super.db);

  Stream<List<Unite>> watchAll() {
    return (db.select(
      db.unites,
    )..orderBy([(t) => OrderingTerm.asc(t.nom)])).watch();
  }

  Future<List<Unite>> getAll() {
    return (db.select(
      db.unites,
    )..orderBy([(t) => OrderingTerm.asc(t.nom)])).get();
  }

  Future<List<Unite>> getByTypeGrandeur(TypeGrandeur typeGrandeur) {
    return (db.select(db.unites)
          ..where((t) => t.typeGrandeur.equalsValue(typeGrandeur))
          ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
        .get();
  }

  Future<Unite> getById(int id) {
    return (db.select(db.unites)..where((t) => t.id.equals(id))).getSingle();
  }
}
