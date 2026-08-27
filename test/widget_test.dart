import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miamo/app/app.dart';
import 'package:miamo/data/database/database_provider.dart';

import 'unit/repositories/test_database.dart';

void main() {
  testWidgets('App démarre avec les 3 onglets de navigation', (
    WidgetTester tester,
  ) async {
    // La base réelle (drift_flutter, fichier + path_provider) n'est pas
    // utilisable dans le test harness : on la remplace par une base en
    // mémoire, comme pour les tests de repositories. Le conteneur est créé
    // manuellement (plutôt que via ProviderScope) pour pouvoir le disposer
    // explicitement avant la fin du test : drift referme ses streams via un
    // Timer.zero, que le test framework signale comme "pending" s'il n'a pas
    // eu l'occasion de s'exécuter avant le teardown.
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(createTestDatabase())],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Frigo'), findsWidgets);
    expect(find.text('Planification'), findsWidgets);
    expect(find.text('Courses'), findsWidgets);

    container.dispose();
    await tester.pump(Duration.zero);
  });
}
