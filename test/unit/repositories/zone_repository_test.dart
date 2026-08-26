import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/zone_repository.dart';
import 'package:miamo/shared/utils/exceptions.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late ZoneRepository repo;

  setUp(() {
    db = createTestDatabase();
    repo = ZoneRepository(db);
  });

  tearDown(() => db.close());

  test('seed crée "Frigo" comme zone racine', () async {
    final racine = await repo.getRoot();
    expect(racine.nom, 'Frigo');
    expect(racine.isRoot, isTrue);
  });

  test('create rejette un nom déjà utilisé', () async {
    await repo.create(nom: 'Congélateur');
    expect(
      () => repo.create(nom: 'Congélateur'),
      throwsA(isA<DuplicateNameException>()),
    );
  });

  test('update peut renommer la zone racine', () async {
    final racine = await repo.getRoot();
    final renommee = await repo.update(racine.id, nom: 'Mon frigo');
    expect(renommee.nom, 'Mon frigo');
    expect(renommee.isRoot, isTrue);
  });

  test('delete de la zone racine est bloqué', () async {
    final racine = await repo.getRoot();
    expect(
      () => repo.delete(racine.id),
      throwsA(isA<ElementProtegeException>()),
    );
  });

  test('delete réaffecte les instances vers la zone racine', () async {
    final zone = await repo.create(nom: 'Congélateur');
    final produitId = await db
        .into(db.produits)
        .insert(
          ProduitsCompanion.insert(
            nom: 'Tomate',
            categorieId: 1,
            typeGrandeur: TypeGrandeur.masse,
            uniteDefautId: 1,
          ),
        );
    final instanceId = await db
        .into(db.produitsFrigo)
        .insert(
          ProduitsFrigoCompanion.insert(
            produitId: produitId,
            zoneId: zone.id,
            quantite: 1,
            uniteId: 1,
            dateAjout: DateTime(2026, 1, 1),
          ),
        );

    await repo.delete(zone.id);

    final instance = await (db.select(
      db.produitsFrigo,
    )..where((t) => t.id.equals(instanceId))).getSingle();
    final racine = await repo.getRoot();
    expect(instance.zoneId, racine.id);
  });
}
