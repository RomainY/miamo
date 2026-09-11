import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/database_provider.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/produit_frigo_repository.dart';
import 'package:miamo/data/repositories/produit_repository.dart';
import 'package:miamo/features/frigo/presentation/pages/frigo_page.dart';

import '../unit/repositories/test_database.dart';

/// Raccourci "Retirer 1" (demande du 11/09/2026) : visible uniquement pour
/// un produit compté à l'unité (ex. "yaourts x6"), pas pour une masse/volume.
void main() {
  Future<ProviderContainer> pumpFrigo(WidgetTester tester) async {
    final db = createTestDatabase();
    final produitRepo = ProduitRepository(db);
    final frigoRepo = ProduitFrigoRepository(db);

    final yaourts = await produitRepo.create(
      nom: 'Yaourts nature',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.unite,
      uniteDefautId: 7, // pièce (grandeur "unite")
    );
    await frigoRepo.create(
      produitId: yaourts.id,
      zoneId: 1,
      quantite: 6,
      uniteId: 7,
    );

    final farine = await produitRepo.create(
      nom: 'Farine',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.masse,
      uniteDefautId: 1,
    );
    await frigoRepo.create(
      produitId: farine.id,
      zoneId: 1,
      quantite: 500,
      uniteId: 1,
    );

    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await tester.pump(Duration.zero);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: FrigoPage()),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
    '"Retirer 1" apparaît pour un produit compté (pièce), pas pour une masse',
    (tester) async {
      await pumpFrigo(tester);

      expect(find.byTooltip('Retirer 1'), findsOneWidget);
    },
  );

  testWidgets(
    'taper "Retirer 1" décrémente la quantité affichée',
    (tester) async {
      await pumpFrigo(tester);

      await tester.tap(find.byTooltip('Retirer 1'));
      await tester.pumpAndSettle();

      expect(find.textContaining('5 pièce'), findsOneWidget);
      expect(find.textContaining('6 pièce'), findsNothing);
    },
  );

  testWidgets(
    'à 0, l\'instance disparaît de la liste (passée à consommé)',
    (tester) async {
      final container = await pumpFrigo(tester);
      final db = container.read(appDatabaseProvider);
      final frigoRepo = ProduitFrigoRepository(db);
      final yaourts = await (db.select(
        db.produits,
      )..where((t) => t.nom.equals('Yaourts nature'))).getSingle();
      final instance = await (db.select(
        db.produitsFrigo,
      )..where((t) => t.produitId.equals(yaourts.id))).getSingle();

      // Vide le reste du stock directement (5 taps équivalents).
      for (var i = 0; i < 5; i++) {
        await frigoRepo.retirerUn(instance.id);
      }
      await tester.pump();

      await tester.tap(find.byTooltip('Retirer 1'));
      await tester.pumpAndSettle();

      expect(find.text('Yaourts nature'), findsNothing);
    },
  );
}
