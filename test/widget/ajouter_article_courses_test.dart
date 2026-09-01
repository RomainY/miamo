import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/database_provider.dart';
import 'package:miamo/features/courses/presentation/pages/ajouter_article_sheet.dart';

import '../unit/repositories/test_database.dart';

void main() {
  Future<ProviderContainer> pumpSheet(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(createTestDatabase())],
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
                onPressed: () => showAjouterArticleSheet(context),
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('le champ Quantité reste masqué tant qu\'aucun produit n\'est '
      'choisi', (tester) async {
    await pumpSheet(tester);

    expect(find.widgetWithText(TextField, 'Quantité'), findsNothing);

    // Passage en "Nouveau produit" : toujours pas de quantité sans nom.
    await tester.tap(find.text('Nouveau produit'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Quantité'), findsNothing);
  });

  testWidgets('création d\'un nouveau produit depuis la liste de courses', (
    tester,
  ) async {
    final container = await pumpSheet(tester);

    await tester.tap(find.text('Nouveau produit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nom du produit'),
      'Sel',
    );
    await tester.pumpAndSettle();

    // Les valeurs par défaut (Non classé / Masse / gramme) rendent la saisie
    // complète : le champ quantité apparaît.
    expect(find.widgetWithText(TextField, 'Quantité'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Quantité'), '2');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Ajouter à la liste'));
    await tester.pumpAndSettle();

    // La feuille s'est fermée, le produit et l'article sont persistés.
    expect(find.text('Ajouter un article'), findsNothing);
    final db = container.read(appDatabaseProvider);
    final produits = await db.select(db.produits).get();
    expect(produits.map((p) => p.nom), contains('Sel'));
    final articles = await db.select(db.articlesCourse).get();
    expect(articles, hasLength(1));
    expect(articles.single.quantite, 2);
    expect(articles.single.produitId, produits.single.id);
  });
}
