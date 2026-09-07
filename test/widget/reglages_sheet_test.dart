import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // `flutter_local_notifications` communique par un unique MethodChannel :
  // sans handler mock, un appel (initialize/show/zonedSchedule/...) reste en
  // attente indéfiniment dans l'environnement de test (pas de plateforme
  // réelle pour répondre), ce qui bloquerait les tests des outils de debug
  // notifications (§ plus bas) au lieu d'échouer proprement.
  const canalNotifications = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  // `NotificationService._assurerInitialisation` interroge aussi le fuseau
  // horaire (`flutter_timezone`) avant toute autre chose — sans mock, cet
  // appel reste également en attente indéfiniment en environnement de test.
  const canalFuseauHoraire = MethodChannel('flutter_timezone');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canalNotifications, (call) async {
          if (call.method == 'pendingNotificationRequests') {
            return <Object?>[];
          }
          return true;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          canalFuseauHoraire,
          (call) async => 'Europe/Paris',
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canalNotifications, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canalFuseauHoraire, null);
  });

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

  group('Outils de debug notifications (07/09/2026, kDebugMode)', () {
    // `flutter test` tourne toujours en mode debug : la section est donc
    // visible ici comme elle le serait dans l'app en dev (jamais en release).
    // La liste de réglages dépasse le viewport de test : on scrolle jusqu'à
    // la section debug (en bas) avant d'interagir, comme le ferait un
    // utilisateur sur l'écran réel.
    Future<void> scrollerJusquauDebug(WidgetTester tester, Finder cible) =>
        tester.dragUntilVisible(
          cible,
          find.byType(ListView),
          const Offset(0, -300),
        );

    testWidgets('affiche un aperçu du calendrier avec joursAvant+2 rappels '
        '(réglages par défaut : J-2 -> 4 rappels)', (tester) async {
      await pumpSheet(tester);
      final titre = find.text('Aperçu du calendrier de rappels');

      await scrollerJusquauDebug(tester, titre);
      await tester.pumpAndSettle();

      expect(titre, findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(4));
    });

    testWidgets(
      "changer la date de l'aperçu ne casse rien et reste cohérent",
      (tester) async {
        await pumpSheet(tester);
        final bouton = find.text('Changer la date');

        await scrollerJusquauDebug(tester, bouton);
        await tester.pumpAndSettle();
        await tester.tap(bouton);
        await tester.pumpAndSettle();
        // Sélectionne le jour déjà en évidence (aujourd'hui + 3) sans
        // changer de mois : referme juste le sélecteur avec "OK".
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.byType(Chip), findsNWidgets(4));
      },
    );

    // Le plugin `flutter_local_notifications` ne s'initialise pas vraiment
    // hors d'une plateforme réelle (il lève une `LateInitializationError`
    // interne même une fois son unique MethodChannel mocké) — attendu, ces
    // outils servent à des essais sur device, pas à une couverture de test
    // du plugin lui-même. On vérifie seulement que l'échec, ici garanti, est
    // bien rattrapé (pas de plantage, un retour visible), pas son contenu
    // exact — sur un vrai appareil, l'action aboutit et affiche le message
    // de succès correspondant à la place.
    testWidgets(
      'taper "Envoyer" ne plante jamais, quel que soit le résultat',
      (tester) async {
        await pumpSheet(tester);
        final bouton = find.text('Envoyer');

        await scrollerJusquauDebug(tester, bouton);
        await tester.pumpAndSettle();
        await tester.tap(bouton);
        // `pump()` court, pas `pumpAndSettle()` : le SnackBar se ferme tout
        // seul après quelques secondes, `pumpAndSettle()` avancerait le
        // temps virtuel jusque-là et le manquerait.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'taper "Voir" (notifications programmées) ne plante jamais',
      (tester) async {
        await pumpSheet(tester);
        final bouton = find.text('Voir');

        await scrollerJusquauDebug(tester, bouton);
        await tester.pumpAndSettle();
        await tester.tap(bouton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
        // Selon l'environnement : soit le dialogue de la liste (succès),
        // soit un SnackBar d'échec (attendu ici, cf. commentaire ci-dessus).
        expect(
          find.byType(AlertDialog).evaluate().isNotEmpty ||
              find.byType(SnackBar).evaluate().isNotEmpty,
          isTrue,
        );
      },
    );
  });
}
