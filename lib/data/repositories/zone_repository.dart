import 'package:drift/drift.dart';

import '../../shared/utils/exceptions.dart';
import '../database/app_database.dart';
import 'base_repository.dart';

/// CRUD complet sur le catalogue des zones (cahier-des-charges.md §7.2).
///
/// La zone racine "Frigo" (`isRoot`, seedée au premier lancement) est la
/// cible de réaffectation automatique des instances d'une zone supprimée ;
/// elle est modifiable (nom, icône) mais jamais supprimable.
class ZoneRepository extends BaseRepository {
  const ZoneRepository(super.db);

  Stream<List<Zone>> watchAll() {
    return (db.select(
      db.zones,
    )..orderBy([(t) => OrderingTerm.asc(t.nom)])).watch();
  }

  Future<List<Zone>> getAll() {
    return (db.select(
      db.zones,
    )..orderBy([(t) => OrderingTerm.asc(t.nom)])).get();
  }

  Future<Zone> getRoot() {
    return (db.select(
      db.zones,
    )..where((t) => t.isRoot.equals(true))).getSingle();
  }

  Future<Zone> create({required String nom, String? icone}) async {
    await _verifierNomLibre(nom);
    final id = await db
        .into(db.zones)
        .insert(
          ZonesCompanion.insert(
            nom: nom,
            icone: icone == null ? const Value.absent() : Value(icone),
          ),
        );
    return _getById(id);
  }

  Future<Zone> update(int id, {String? nom, String? icone}) async {
    if (nom != null) {
      await _verifierNomLibre(nom, exclureId: id);
    }
    await (db.update(db.zones)..where((t) => t.id.equals(id))).write(
      ZonesCompanion(
        nom: nom == null ? const Value.absent() : Value(nom),
        icone: icone == null ? const Value.absent() : Value(icone),
      ),
    );
    return _getById(id);
  }

  /// Supprime une zone et réaffecte ses instances vers la zone racine.
  /// Lève [ElementProtegeException] pour la zone racine elle-même.
  Future<void> delete(int id) async {
    final zone = await _getById(id);
    if (zone.isRoot) {
      throw const ElementProtegeException(
        'La zone racine "Frigo" ne peut pas être supprimée.',
      );
    }

    await db.transaction(() async {
      final racine = await getRoot();
      await (db.update(db.produitsFrigo)..where((t) => t.zoneId.equals(id)))
          .write(ProduitsFrigoCompanion(zoneId: Value(racine.id)));
      await (db.delete(db.zones)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<Zone> _getById(int id) {
    return (db.select(db.zones)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> _verifierNomLibre(String nom, {int? exclureId}) async {
    final query = db.select(db.zones)..where((t) => t.nom.equals(nom));
    final existant = await query.getSingleOrNull();
    if (existant != null && existant.id != exclureId) {
      throw const DuplicateNameException('Cette zone existe déjà.');
    }
  }
}
