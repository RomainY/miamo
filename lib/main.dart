import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Filet de sécurité : toute erreur non rattrapée (framework Flutter ou
  // isolate principal) est tracée plutôt que simplement écrite sur la console
  // du moteur. L'app étant 100% hors-ligne, on se contente d'un log local
  // (pas de service de crash reporting distant).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      'Erreur Flutter non rattrapée',
      name: 'miamo.error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      'Erreur non rattrapée (isolate)',
      name: 'miamo.error',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  await initializeDateFormatting('fr_FR');
  runApp(const ProviderScope(child: App()));
}
