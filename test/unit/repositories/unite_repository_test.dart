import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/unite_repository.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late UniteRepository repo;

  setUp(() {
    db = createTestDatabase();
    repo = UniteRepository(db);
  });

  tearDown(() => db.close());

  test('le seed fournit les 7 unités de base', () async {
    final unites = await repo.getAll();
    expect(
      unites.map((u) => u.nom),
      containsAll(<String>['gramme', 'litre', 'pièce']),
    );
    expect(unites, hasLength(7));
  });

  test('getAll trie par nom', () async {
    final noms = (await repo.getAll()).map((u) => u.nom).toList();
    final tries = [...noms]..sort();
    expect(noms, tries);
  });

  test(
    'getByTypeGrandeur ne renvoie que les unités de la grandeur demandée',
    () async {
      final masses = await repo.getByTypeGrandeur(TypeGrandeur.masse);
      expect(
        masses.map((u) => u.nom),
        unorderedEquals(<String>['gramme', 'kilogramme']),
      );
      expect(masses.every((u) => u.typeGrandeur == TypeGrandeur.masse), isTrue);

      final unites = await repo.getByTypeGrandeur(TypeGrandeur.unite);
      expect(unites.single.nom, 'pièce');
    },
  );

  test('facteurVersBase : le gramme vaut 1, le kilogramme 1000', () async {
    final masses = await repo.getByTypeGrandeur(TypeGrandeur.masse);
    final gramme = masses.firstWhere((u) => u.nom == 'gramme');
    final kilo = masses.firstWhere((u) => u.nom == 'kilogramme');
    expect(gramme.facteurVersBase, 1);
    expect(kilo.facteurVersBase, 1000);
  });

  test('getById renvoie l\'unité correspondante', () async {
    final premier = (await repo.getAll()).first;
    final relu = await repo.getById(premier.id);
    expect(relu.nom, premier.nom);
  });

  test('watchAll émet la liste courante', () async {
    await expectLater(repo.watchAll().map((liste) => liste.length), emits(7));
  });
}
