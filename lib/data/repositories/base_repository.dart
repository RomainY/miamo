import '../database/app_database.dart';

/// Base commune aux repositories : détient la référence à la base et
/// centralise les helpers partagés (aucune logique métier ici).
abstract class BaseRepository {
  final AppDatabase db;
  const BaseRepository(this.db);
}
