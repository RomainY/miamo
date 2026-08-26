import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/courses/presentation/pages/courses_page.dart';
import '../features/frigo/presentation/pages/frigo_page.dart';
import '../features/planification/presentation/pages/planification_page.dart';
import '../shared/services/notification_providers.dart';
import '../shared/theme/app_theme.dart';

/// Cf. documentation-technique.md §4 "Découpage en 3 features principales :
/// frigo, planification, courses".
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miamo',
      theme: buildAppTheme(),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _RootShell(),
    );
  }
}

class _RootShell extends ConsumerStatefulWidget {
  const _RootShell();

  @override
  ConsumerState<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<_RootShell> {
  int _index = 0;

  static const _pages = [FrigoPage(), PlanificationPage(), CoursesPage()];

  @override
  Widget build(BuildContext context) {
    // Maintient les notifications de péremption à jour quel que soit
    // l'onglet affiché (cf. shared/services/notification_providers.dart).
    ref.watch(notificationSyncProvider);

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            label: 'Frigo',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Planification',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Courses',
          ),
        ],
      ),
    );
  }
}
