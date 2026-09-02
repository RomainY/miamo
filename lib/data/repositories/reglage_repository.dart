import '../database/app_database.dart';
import 'base_repository.dart';

/// Clé du consentement à la recherche en ligne Open Food Facts
/// (`'true'` / `'false'` ; absente = jamais demandé).
/// Cf. Docs/poc-scan-code-barres.md §5.7.
const kReglageRechercheEnLigne = 'recherche_en_ligne_off';

/// Accès aux réglages applicatifs simples (table `reglage`, clé/valeur texte).
class ReglageRepository extends BaseRepository {
  const ReglageRepository(super.db);

  Future<String?> lire(String cle) async {
    final ligne = await (db.select(
      db.reglages,
    )..where((t) => t.cle.equals(cle))).getSingleOrNull();
    return ligne?.valeur;
  }

  Future<void> ecrire(String cle, String valeur) async {
    await db
        .into(db.reglages)
        .insertOnConflictUpdate(ReglagesCompanion.insert(cle: cle, valeur: valeur));
  }

  /// `null` si le réglage n'a jamais été fixé.
  Future<bool?> lireBool(String cle) async {
    final brut = await lire(cle);
    return switch (brut) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }

  Future<void> ecrireBool(String cle, bool valeur) =>
      ecrire(cle, valeur ? 'true' : 'false');

  Stream<String?> observer(String cle) {
    return (db.select(db.reglages)..where((t) => t.cle.equals(cle)))
        .watchSingleOrNull()
        .map((ligne) => ligne?.valeur);
  }
}
