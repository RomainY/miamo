import 'package:drift/native.dart';
import 'package:miamo/data/database/app_database.dart';

/// Base en mémoire pour les tests, avec le même seed (`Non classé`, `Frigo`,
/// unités de base) que la base réelle — `onCreate` est déclenché à la
/// première ouverture, comme pour un fichier.
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
