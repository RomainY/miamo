import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/repositories/reglage_repository.dart';

import 'test_database.dart';

void main() {
  late final db = createTestDatabase();
  final repo = ReglageRepository(db);

  tearDownAll(() => db.close());

  test('lire renvoie null pour une clé absente', () async {
    expect(await repo.lire('inconnue'), isNull);
    expect(await repo.lireBool('inconnue'), isNull);
  });

  test('ecrire puis lire', () async {
    await repo.ecrire('couleur', 'bleu');
    expect(await repo.lire('couleur'), 'bleu');
  });

  test('ecrire écrase la valeur existante (upsert)', () async {
    await repo.ecrire('couleur', 'rouge');
    await repo.ecrire('couleur', 'vert');
    expect(await repo.lire('couleur'), 'vert');
  });

  test('bool : true / false / null', () async {
    await repo.ecrireBool(kReglageRechercheEnLigne, true);
    expect(await repo.lireBool(kReglageRechercheEnLigne), isTrue);
    await repo.ecrireBool(kReglageRechercheEnLigne, false);
    expect(await repo.lireBool(kReglageRechercheEnLigne), isFalse);
  });

  test('observer émet la valeur courante puis se met à jour', () async {
    await repo.ecrire('flux', 'a');
    expect(await repo.observer('flux').first, 'a');
    await repo.ecrire('flux', 'b');
    expect(await repo.observer('flux').first, 'b');
  });

  test('lireInt renvoie le défaut pour une clé absente ou non entière', () async {
    expect(await repo.lireInt('inconnue', defaut: 42), 42);
    await repo.ecrire('pasUnNombre', 'abc');
    expect(await repo.lireInt('pasUnNombre', defaut: 42), 42);
  });

  test('ecrireInt puis lireInt', () async {
    await repo.ecrireInt(kReglageSeuilFrequenceRupture, 5);
    expect(
      await repo.lireInt(kReglageSeuilFrequenceRupture, defaut: 3),
      5,
    );
  });

  test('observerInt émet le défaut puis la valeur écrite', () async {
    expect(
      await repo.observerInt('seuilInconnu', defaut: 7).first,
      7,
    );
    await repo.ecrireInt('seuilInconnu', 9);
    expect(
      await repo.observerInt('seuilInconnu', defaut: 7).first,
      9,
    );
  });
}
