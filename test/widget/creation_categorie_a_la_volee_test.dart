import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/database_provider.dart';
import 'package:miamo/features/frigo/presentation/pages/produit_form_sheet.dart';

import '../unit/repositories/test_database.dart';

void main() {
  testWidgets(
    'création produit + nouvelle catégorie à la volée : la validation aboutit',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(createTestDatabase()),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await tester.pump(Duration.zero);
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showProduitFormSheet(context),
                  child: const Text('ouvrir'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();

      // Nom du produit
      await tester.enterText(
        find.widgetWithText(TextField, 'Nom du produit'),
        'Tomate',
      );
      await tester.pump();

      // Ouvre le dialogue "Nouvelle catégorie"
      await tester.tap(find.byTooltip('Nouvelle catégorie'));
      await tester.pumpAndSettle();

      // Saisit le nom de la catégorie et valide
      await tester.enterText(find.widgetWithText(TextField, 'Nom'), 'Boissons');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Valider'));
      await tester.pumpAndSettle();

      // Le dialogue doit être fermé et la catégorie sélectionnée dans la fiche
      expect(find.text('Valider'), findsNothing);
      expect(find.text('Boissons'), findsOneWidget);

      // Valide la création du produit
      await tester.tap(find.widgetWithText(FilledButton, 'Créer le produit'));
      await tester.pumpAndSettle();

      // La fiche doit s'être fermée et le produit persisté
      expect(find.text('Nouveau produit'), findsNothing);
      final db = container.read(appDatabaseProvider);
      final produits = await db.select(db.produits).get();
      expect(produits.map((p) => p.nom), contains('Tomate'));
    },
  );
}
