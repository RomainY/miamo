import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/database_provider.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/produit_repository.dart';
import 'package:miamo/features/planification/presentation/pages/ajouter_ingredient_sheet.dart';

import '../unit/repositories/test_database.dart';

/// Régression : deux problèmes signalés en test manuel (05/09/2026) sur la
/// sheet d'ajout d'ingrédient à un plat.
void main() {
  Future<ProviderContainer> pumpSheet(WidgetTester tester) async {
    final db = createTestDatabase();
    await ProduitRepository(db).create(
      nom: 'Farine',
      categorieId: 1,
      typeGrandeur: TypeGrandeur.masse,
      uniteDefautId: 1, // gramme
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
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAjouterIngredientSheet(context),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Farine'));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
    'aucun débordement (bottom overflow) même avec un clavier occupant '
    "une grande partie de l'écran",
    (tester) async {
      // Écran réduit + clavier simulé (viewInsets.bottom) : condition qui
      // provoquait le "BOTTOM OVERFLOWED" avant le passage en
      // SingleChildScrollView.
      tester.view.physicalSize = const Size(400, 500);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await pumpSheet(tester);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('un produit "masse" propose plusieurs unités compatibles, '
      'sélectionnables', (tester) async {
    await pumpSheet(tester);

    // gramme (défaut) et kilogramme (seedés en masse) doivent être proposés.
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    expect(find.text('gramme').hitTestable(), findsWidgets);
    expect(find.text('kilogramme').hitTestable(), findsOneWidget);

    await tester.tap(find.text('kilogramme').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Quantité'), '2');
    await tester.pump();
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    // La sheet doit s'être fermée (résultat renvoyé, plus besoin de vérifier
    // la valeur ici : le contrat est couvert par le renvoi de `uniteId`).
    expect(find.text('Ajouter un ingrédient'), findsNothing);
  });
}
