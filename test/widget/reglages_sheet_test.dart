import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/database_provider.dart';
import 'package:miamo/data/repositories/reglage_repository.dart';
import 'package:miamo/features/parametres/presentation/widgets/reglages_sheet.dart';

import '../unit/repositories/test_database.dart';

/// Vérifie l'écran Paramètres (`Docs/poc-liste-courses-auto.md` §11) : les
/// réglages s'écrivent au vol, et les bornes numériques (§11.2) sont
/// appliquées.
void main() {
  Future<ProviderContainer> pumpSheet(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(createTestDatabase())],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: ReglagesSheet()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
    'désactiver l\'interrupteur "rachat fréquent" écrit false en base',
    (tester) async {
      final container = await pumpSheet(tester);

      await tester.tap(find.text('Suggestions de rachat fréquent'));
      await tester.pumpAndSettle();

      final reglage = ReglageRepository(container.read(appDatabaseProvider));
      expect(
        await reglage.lireBool(kReglageSuggestionRuptureActive),
        isFalse,
      );
    },
  );

  testWidgets('un seuil saisi au-delà du max (100) est ramené à 100', (
    tester,
  ) async {
    final container = await pumpSheet(tester);

    final champ = find.descendant(
      of: find.widgetWithText(ListTile, 'Période de référence'),
      matching: find.byType(TextField),
    );
    await tester.enterText(champ, '500');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final reglage = ReglageRepository(container.read(appDatabaseProvider));
    expect(
      await reglage.lireInt(kReglagePeriodeRuptureJours, defaut: -1),
      100,
    );
  });

  testWidgets('un seuil de rupture saisi à 0 est ramené au minimum (1)', (
    tester,
  ) async {
    final container = await pumpSheet(tester);

    final champ = find.descendant(
      of: find.widgetWithText(ListTile, 'Achats rapprochés avant suggestion'),
      matching: find.byType(TextField),
    );
    await tester.enterText(champ, '0');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final reglage = ReglageRepository(container.read(appDatabaseProvider));
    expect(
      await reglage.lireInt(kReglageSeuilFrequenceRupture, defaut: -1),
      1,
    );
  });

  testWidgets('l\'alerte de péremption accepte 0 (le jour même)', (
    tester,
  ) async {
    final container = await pumpSheet(tester);

    final champ = find.descendant(
      of: find.widgetWithText(ListTile, 'Alerte sur le frigo'),
      matching: find.byType(TextField),
    );
    await tester.enterText(champ, '0');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final reglage = ReglageRepository(container.read(appDatabaseProvider));
    expect(
      await reglage.lireInt(kReglageSeuilAlerteBandeauJours, defaut: -1),
      0,
    );
  });
}
