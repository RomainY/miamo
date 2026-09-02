import 'package:drift/drift.dart' show Value;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/seeders.dart' show categoriesDeBase;
import 'package:miamo/data/database/tables.dart';

import '../../generated/schema.dart';

/// Migrations de schéma (cf. `app_database.dart` & `Docs/poc-scan-code-barres.md`
/// §4) :
///  - **v1 → v2** : `produit.code_barre` (nullable) + index UNIQUE
///    `ux_produit_code_barre`.
///  - **v2 → v3** : table `reglage` (clé/valeur).
///  - **v3 → v4** : injection des `categoriesDeBase` (INSERT OR IGNORE).
///
/// Snapshots (`drift_schemas/`) et helpers (`test/generated/`) régénérés via :
///   dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
///   dart run drift_dev schema generate drift_schemas/ test/generated/
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  for (final from in [1, 2, 3]) {
    test('le schéma après migration v$from → v4 correspond au schéma généré', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase.forTesting(connection);
      addTearDown(db.close);

      await verifier.migrateAndValidate(db, 4);
    });
  }

  test('v3 → v4 injecte les catégories de base sans doublonner les existantes', () async {
    final schema = await verifier.schemaAt(3);
    // L'utilisateur avait déjà créé « Frais » à la main.
    schema.rawDatabase.execute(
      "INSERT INTO categorie (nom, icone, est_par_defaut) VALUES ('Frais', 'category', 0)",
    );

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 4);

    final noms =
        (await db.select(db.categories).get()).map((c) => c.nom).toList();
    expect(noms, containsAll(categoriesDeBase));
    expect(noms.where((n) => n == 'Frais'), hasLength(1));
  });

  test('v1 → v4 préserve les produits existants (code_barre = NULL)', () async {
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute(
      "INSERT INTO categorie (id, nom, icone, est_par_defaut) VALUES (1, 'Non classé', 'category', 1)",
    );
    schema.rawDatabase.execute(
      "INSERT INTO unite (id, nom, type_grandeur, facteur_vers_base) VALUES (1, 'gramme', 'masse', 1.0)",
    );
    schema.rawDatabase.execute(
      "INSERT INTO produit (id, nom, categorie_id, type_grandeur, unite_defaut_id, statut) VALUES (1, 'Tomate', 1, 'masse', 1, 'actif')",
    );

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 4);

    final produits = await db.select(db.produits).get();
    expect(produits, hasLength(1));
    expect(produits.single.nom, 'Tomate');
    expect(produits.single.codeBarre, isNull);
  });

  test('après migration : code_barre unique, plusieurs NULL tolérés', () async {
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute(
      "INSERT INTO categorie (id, nom, icone, est_par_defaut) VALUES (1, 'Non classé', 'category', 1)",
    );
    schema.rawDatabase.execute(
      "INSERT INTO unite (id, nom, type_grandeur, facteur_vers_base) VALUES (1, 'gramme', 'masse', 1.0)",
    );

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 4);

    ProduitsCompanion produit(String nom, {String? code}) =>
        ProduitsCompanion.insert(
          nom: nom,
          categorieId: 1,
          typeGrandeur: TypeGrandeur.masse,
          uniteDefautId: 1,
          codeBarre: Value(code),
        );

    await db.into(db.produits).insert(produit('Tomate'));
    await db.into(db.produits).insert(produit('Carotte'));
    await db
        .into(db.produits)
        .insert(produit('Yaourt nature', code: '3033710065967'));
    await expectLater(
      db
          .into(db.produits)
          .insert(produit('Yaourt sucré', code: '3033710065967')),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('UNIQUE'),
        ),
      ),
    );
  });

  test('v2 → v4 : la table reglage est utilisable après migration', () async {
    final connection = await verifier.startAt(2);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 4);

    await db
        .into(db.reglages)
        .insert(ReglagesCompanion.insert(cle: 'x', valeur: 'true'));
    final ligne = await (db.select(db.reglages)
          ..where((t) => t.cle.equals('x')))
        .getSingle();
    expect(ligne.valeur, 'true');
  });
}
