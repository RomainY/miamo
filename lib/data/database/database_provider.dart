import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Instance unique de la base locale, fermée à la destruction du conteneur
/// Riverpod (fin d'app / tests).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
