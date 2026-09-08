import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/app/app.dart';
import 'package:miamo/data/database/database_provider.dart';

import '../unit/repositories/test_database.dart';

/// Vérifie la réorganisation de navigation
/// (`Docs/poc-anti-gaspi-et-navigation.md` §B.2) : un menu "Gestion"
/// (icône ⚙, appelé "Plus" en interne jusqu'au 08/09/2026) identique sur les
/// 3 onglets, Réglages remonté au même niveau que Catalogue/Mes
/// plats/Anti-gaspi (n'est plus niché dans Catalogue). Les icônes directes
/// ⚙ (Catalogue, sur Frigo) et 📖 (Mes plats, sur Planification) ont été
/// retirées une fois "Gestion" en place : ces écrans ne sont plus
/// accessibles que via "Gestion".
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(createTestDatabase())],
    );
    addTearDown(() async {
      container.dispose();
      await tester.pump(Duration.zero);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> ouvrirGestion(WidgetTester tester) async {
    await tester.tap(find.widgetWithIcon(IconButton, Icons.settings_outlined).first);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'l\'icône "Gestion" de Frigo ouvre les 4 entrées attendues',
    (tester) async {
      await pumpApp(tester);
      await ouvrirGestion(tester);

      expect(find.text('Gestion'), findsOneWidget);
      expect(find.text('Gérer le catalogue'), findsOneWidget);
      expect(find.text('Mes plats'), findsOneWidget);
      expect(find.text('Statistiques anti-gaspi'), findsOneWidget);
      expect(find.text('Réglages'), findsOneWidget);
    },
  );

  testWidgets(
    'Réglages est accessible directement depuis "Gestion", sans passer par '
    'Catalogue',
    (tester) async {
      await pumpApp(tester);
      await ouvrirGestion(tester);
      await tester.tap(find.text('Réglages'));
      await tester.pumpAndSettle();

      // AppBar "Réglages" (le titre) + un réglage connu pour confirmer que
      // c'est bien le bon écran.
      expect(find.text('Réglages'), findsWidgets);
      expect(find.text('Suggestions selon mes repas planifiés'), findsOneWidget);
    },
  );

  testWidgets(
    'Frigo/Planification n\'affichent plus les icônes directes ⚙/📖 — '
    'seule "Gestion" reste',
    (tester) async {
      await pumpApp(tester);

      expect(find.byTooltip('Gérer le catalogue'), findsNothing);
      expect(find.byTooltip('Mes plats'), findsNothing);
      expect(find.byTooltip('Gestion'), findsWidgets);
    },
  );

  testWidgets(
    "Catalogue, atteint depuis \"Gestion\", n'a plus de bouton Réglages "
    'imbriqué',
    (tester) async {
      await pumpApp(tester);
      await ouvrirGestion(tester);
      await tester.tap(find.text('Gérer le catalogue'));
      await tester.pumpAndSettle();

      expect(find.text('Catalogue'), findsOneWidget);
      expect(find.byTooltip('Réglages'), findsNothing);
    },
  );

  testWidgets(
    'Statistiques anti-gaspi s\'ouvre sans historique (catalogue vide en '
    'test)',
    (tester) async {
      await pumpApp(tester);
      await ouvrirGestion(tester);
      await tester.tap(find.text('Statistiques anti-gaspi'));
      await tester.pumpAndSettle();

      expect(find.text('Statistiques anti-gaspi'), findsWidgets);
      expect(
        find.text("Pas encore d'historique sur cette période."),
        findsOneWidget,
      );
    },
  );
}
