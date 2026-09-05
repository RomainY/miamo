import '../database/app_database.dart';
import 'base_repository.dart';

/// Clé du consentement à la recherche en ligne Open Food Facts
/// (`'true'` / `'false'` ; absente = jamais demandé).
/// Cf. Docs/poc-scan-code-barres.md §5.7.
const kReglageRechercheEnLigne = 'recherche_en_ligne_off';

// ─── Réglages v1.2 — liste de courses auto + péremption ───────────────────
// Cf. Docs/poc-liste-courses-auto.md §11 "Écran Paramètres". Toutes les
// valeurs numériques sont bornées par [ReglageRepository.lireInt] ; les
// constantes de `shared/utils/constants.dart` restent la valeur de repli tant
// que l'utilisateur n'a rien réglé.

/// Active/désactive la suggestion "ingrédients manquants pour mes repas
/// planifiés" (`'true'`/`'false'`, absent = activé).
const kReglageSuggestionPlanificationActive =
    'suggestion_planification_active';

/// Active/désactive la suggestion "rachat fréquent" (`'true'`/`'false'`,
/// absent = activé).
const kReglageSuggestionRuptureActive = 'suggestion_rupture_active';

/// Nombre d'occurrences consommé/jeté sur [kReglagePeriodeRuptureJours] jours
/// à partir duquel un produit en rupture est suggéré. Min 1 (0 n'a pas de
/// sens : suggérerait un produit jamais racheté).
const kReglageSeuilFrequenceRupture = 'seuil_frequence_rupture';

/// Fenêtre glissante (jours) de l'heuristique de rachat fréquent. Min 1 (0
/// viderait la fenêtre : aucune occurrence ne pourrait jamais compter).
const kReglagePeriodeRuptureJours = 'periode_rupture_jours';

/// Jours restants avant péremption à partir desquels le bandeau d'alerte
/// s'affiche. 0 valide (n'alerter que le jour J / déjà périmé).
const kReglageSeuilAlerteBandeauJours = 'seuil_alerte_bandeau_jours';

/// Jours avant la date de péremption où la notification est programmée. 0
/// valide (notifier le jour même).
const kReglageJoursAvantNotification = 'jours_avant_notification';

/// Heure (0-23) de déclenchement de la notification de péremption.
const kReglageHeureNotification = 'heure_notification';

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

  /// `defaut` si le réglage n'a jamais été fixé ou contient une valeur non
  /// entière (défensif : un fichier de base corrompu/édité à la main ne doit
  /// jamais faire planter un calcul). Ne borne pas la valeur : le clamp
  /// éventuel (min/max, cf. `Docs/poc-liste-courses-auto.md` §11.2) est du
  /// ressort de l'écran qui écrit le réglage, pas de la lecture.
  Future<int> lireInt(String cle, {required int defaut}) async {
    final brut = await lire(cle);
    return brut == null ? defaut : (int.tryParse(brut) ?? defaut);
  }

  Future<void> ecrireInt(String cle, int valeur) =>
      ecrire(cle, valeur.toString());

  Stream<String?> observer(String cle) {
    return (db.select(db.reglages)..where((t) => t.cle.equals(cle)))
        .watchSingleOrNull()
        .map((ligne) => ligne?.valeur);
  }

  /// Version réactive de [lireInt], pour piloter un provider (bandeau,
  /// notifications, seuils de suggestion — cf. §11.4 du POC).
  Stream<int> observerInt(String cle, {required int defaut}) {
    return observer(
      cle,
    ).map((brut) => brut == null ? defaut : (int.tryParse(brut) ?? defaut));
  }
}
