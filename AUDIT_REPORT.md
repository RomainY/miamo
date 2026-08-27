# Rapport d'audit — Miamo

> Audit en 4 phases (contexte, cartographie, sécurité, bonnes pratiques Dart/Flutter).
> État de départ : commit `df7a05a`. Compléments : [`ARCHITECTURE.md`](ARCHITECTURE.md).
> Toolchain constatée : Flutter 3.44.8 / Dart 3.12.2. `flutter analyze` : 0 issue.
> `flutter test` : 36/36. Couverture ≈ 24 % (repositories bien couverts, UI non).

## Synthèse

| | Constat |
|---|---|
| **Points forts** | Null safety exemplaire (0 cast `as`, aucun `!` franchement abusif, `late` propre). Séparation métier/UI nette (toute la logique dans `data/repositories`, transactions systématiques). Exceptions métier typées. `const` systématique. Couche repository bien testée (cascades, FIFO, conversions d'unités, protections). Documentation `///` déjà dense sur les modules critiques. Aucun secret, aucun code réseau, permissions minimales. |
| **À corriger avant mise en production** | Signature `release` = clé de debug (SEC‑07). Aucune obfuscation / séparation des symboles (SEC‑08). Code non conforme à `dart format` actuel — 36 fichiers (BP‑03). |
| **À fiabiliser** | Futures non attendues dans l'UI → échecs silencieux sur des actions cœur comme « Marquer fait » (BP‑06). Décision explicite sur le chiffrement de la base (SEC‑01). Stratégie de migration de schéma (SEC‑02). Couverture de tests UI + `NotificationService` + `unite_repository`. |
| **Risque global** | **Faible.** Aucune vulnérabilité critique ni exploitable à distance — cohérent avec une application 100 % locale, sans compte ni réseau. Les vrais bloquants concernent la chaîne de release, pas la sécurité applicative. |

---

## 1. Sécurité

### 1.1 Tableau des problèmes par criticité

| # | Criticité | Domaine | Emplacement | Problème | Correctif |
|---|---|---|---|---|---|
| **SEC‑07** | **Majeur** | Build release | `android/app/build.gradle.kts:33‑36` | `release { signingConfig = signingConfigs.getByName("debug") }`. Un AAB signé avec la clé de debug n'est pas publiable et re-signable par quiconque. | `key.properties` (gitignoré) + `signingConfigs.release`. |
| **SEC‑08** | **Majeur** | Obfuscation | build / CI / docs (absent) | Aucune trace de `--obfuscate --split-debug-info`. Code Dart release lisible. | Scripter `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols` ; archiver les symboles hors dépôt. Fait dans le `README`. |
| **SEC‑01** | **Majeur à trancher** (sinon Mineur) | Stockage | `lib/data/database/app_database.dart` (`_openConnection`) | Base SQLite **non chiffrée**. `sqlcipher_flutter_libs` présent (via `drift_flutter`) mais aucune clé. Données = frigo/plats/planning, **sans secret ni PII sensible**. | **Recommandé : acter « clair »** (fait : commentaire ajouté dans le code). Sinon chiffrer via `drift_flutter` + clé en `flutter_secure_storage`. |
| **SEC‑10** | Mineur | Logs | `lib/shared/services/notification_service.dart:70‑71` | `// ignore: avoid_print` + `print('… a échoué : $e')` — actif en release (`adb logcat`), peut contenir des noms de produits. | Remplacer par `dart:developer` `log()` ou garde `kDebugMode`. *(auto‑fixable — voir plan)* |
| **SEC‑11** | Mineur | Divulgation UI | ~10 sites `error: (e,_) => Text('Erreur : $e')`, `catch (e) { _erreur = 'Erreur : $e' }` | Détails techniques (contraintes SQL, stack Drift) affichés à l'utilisateur. | Message générique + `log()` du détail. |
| **SEC‑02** | Mineur | Stockage / intégrité | `lib/data/database/app_database.dart:29` | `schemaVersion = 1`, pas d'`onUpgrade` → aucune stratégie de migration. Risque de perte/corruption à la 1ʳᵉ évolution post-release. | `onUpgrade: stepByStep(...)` + procédure documentée. |
| **SEC‑03** | Mineur | Validation | `ajouter_produit_sheet.dart:366`, `modifier_instance_sheet.dart:148`, `produit_form_sheet.dart:226` | `double.tryParse` accepte négatif / 0 / `Infinity`. Garde `> 0` présente dans certains sheets seulement → quantité ≤ 0 possible en base. | Helper commun `quantite > 0 && quantite.isFinite` + `CHECK (quantite > 0)` SQL. |
| **SEC‑04** | Mineur | Intégrité | `lib/data/database/tables.dart` | Invariants portés **uniquement par le code Dart** : `RepasPlanifie` = `platId` XOR `produitId` ; quantités > 0. | Contraintes `CHECK` dans les définitions de table Drift. |
| **SEC‑05** | Mineur | Permissions | `AndroidManifest.xml` + `notification_service.dart` | `RECEIVE_BOOT_COMPLETED` déclarée mais reprogrammation au reboot non vérifiée → notifications potentiellement perdues après redémarrage. | Test fonctionnel post-reboot. |
| **SEC‑06** | Mineur | iOS | `lib/shared/services/notification_service.dart:34` | `InitializationSettings(android: …)` seul — notifications **absentes sur iOS** (pas une faille). | Si iOS entre au périmètre : conf `DarwinInitializationSettings` + clés Info.plist. |
| **SEC‑09** | Mineur | Build release | `android/app/build.gradle.kts` (bloc `release`) | Pas de `isMinifyEnabled` / `proguard-rules.pro`. R8 par défaut en release Flutter mais survie des notifs au shrink non validée. | Build release réel + test des notifications ; `proguard-rules.pro` si besoin. |
| **SEC‑13** | Mineur | Repro build | `.fvmrc` (vide) | Flutter/Dart non épinglé → build non reproductible. | Renseigner `.fvmrc` ou documenter la version. |
| **SEC‑12** | Info | Dépendances | (process) | `osv-scanner` indisponible, pas de scan CVE automatisé. Revue manuelle : toutes les deps directes populaires, maintenues, hébergées pub.dev, aucune git/fork. `flutter_riverpod` 2.6.1 (1 majeure de retard) ≠ CVE. | Ajouter `osv-scanner` / `dart pub audit` en CI ; re-scan OSV avec réseau. |
| **SEC‑14** | Info | Doc | `Docs/PRE-LAUNCH-CHECKLIST.md` | Recommande de gitignorer `pubspec.lock` ; le `.gitignore` réel fait — correctement — l'inverse. | Corriger la doc. |

### 1.2 Points vérifiés — conformes ✅

- **Secrets en dur** : grep `api_key|secret|password|token|bearer|credential|private_key` sur `lib/ android/ ios/ web/` → néant. App sans auth ni API tierce.
- **Injection SQL** : Drift = requêtes 100 % paramétrées. Seul `customStatement` = `PRAGMA foreign_keys = ON` (constante). Aucun `customSelect`/`rawQuery` concaténé.
- **Désérialisation** : aucun `jsonDecode` / `fromJson`.
- **Réseau / TLS** : aucun code réseau. Aucune désactivation de vérification SSL (`badCertificateCallback`, `HttpOverrides`, `NSAllowsArbitraryLoads`, `usesCleartextTraffic`). `INTERNET` absente du manifest release. Certificate pinning : N/A.
- **Permissions Android** : moindre privilège — `POST_NOTIFICATIONS` + `RECEIVE_BOOT_COMPLETED` seulement, toutes deux utilisées/justifiées.
- **`PRAGMA foreign_keys = ON`** activé à chaque ouverture.
- **Deep links / platform channels** : aucun (surface d'attaque nulle de ce côté).
- **Artefacts de build** (`build/`, `.gradle/`, `.dart_tool/`) : non versionnés.

---

## 2. Bonnes pratiques Dart / Flutter

| # | Sévérité | Thème | Emplacement | Écart | Correctif |
|---|---|---|---|---|---|
| **BP‑03** | **Majeur** | Formatage | 36 / 58 fichiers `lib/`+`test/` | Non conforme à `dart format` de Dart 3.12 (formateur « tall »). Code formaté avec l'ancien style. `flutter analyze` ne le voit pas. | `dart format lib test` **dans un commit dédié isolé**. Ajouter à un hook pre-commit / CI. *(auto‑fixable — voir plan)* |
| **BP‑06** | **Majeur** | Gestion d'erreurs | `frigo_page` (`marquerConsomme`/`marquerJete`), `article_course_tile` (`marquerAchete`/`supprimer`), `repas_list_tile` (`marquerFait`/`annuler`), `gerer_catalogue_page:122‑123` (`archiver`/`desarchiver`) | Futures non attendues, sans `catch`. `marquerFait` fait le décompte FIFO transactionnel et peut lever `StateError` → l'utilisateur tape le bouton, **rien ne se passe**, stock non décrémenté. | `await` + `try/catch` avec retour visuel (SnackBar). Activer le lint `unawaited_futures`. |
| BP‑01 | Mineur | Null safety | `_valider()` de 5 sheets (`ajouter_produit_sheet:395‑410`, `produit_form_sheet:250‑252`, `planifier_repas_sheet:241‑242`, `ajouter_article_sheet:157‑159`, `ajouter_ingredient_sheet:150‑152`) | Déréférencement `_x!` en s'appuyant sur `_peutValider()` (méthode séparée) pour la non-nullité. Couple désynchronisable → NPE. | Locales non-nullables + `return` en tête de `_valider()`, ou objet de formulaire validé. |
| BP‑02 | Mineur | Null safety | `modifier_instance_sheet.dart:81` | `onChanged: (v) => _zoneId = v!` sur `int?`. | `_zoneId = v` (garder la dernière valeur non nulle). |
| BP‑05 | Mineur | Séparation UI/métier | `planification_page.dart:88‑95`, `courses_page.dart:25‑30`, `expiration_warning_banner.dart:20‑23` | Agrégation/regroupement/filtre recalculés dans `build()` à chaque rebuild. | Déplacer dans un `Provider` dérivé / `select`. |
| BP‑07 | Mineur | Gestion d'erreurs | `ajouter_produit_sheet:416/418`, `produit_form_sheet:257/259`, `planifier_repas_sheet:247`, `plat_detail_screen:286` | `setState(() => _erreur = …)` dans un `catch` **sans garde `mounted`** (le `finally` et le succès l'ont). | Ajouter `if (!mounted) return;` avant ces `setState`. |
| BP‑08 | Mineur | Gestion d'erreurs | `repas_planifie_repository.dart` (`marquerFait` → `StateError`, `planifier` → `ArgumentError`) ; `plat_detail_screen._enregistrer` (pas de `catch` générique) ; `nom_dialog` (catche seulement `DuplicateNameException`) | Types `Error` (bugs de prog) utilisés pour des conditions runtime récupérables ; couverture `catch` inégale entre sheets. | Étendre `exceptions.dart` (`StatutInvalideException`…) ; homogénéiser le `catch` des sheets. |
| BP‑10 | Mineur | Robustesse | `lib/main.dart` | Pas de `FlutterError.onError` / `PlatformDispatcher.instance.onError` / `runZonedGuarded`. | Ajouter des handlers globaux (au minimum log). |
| BP‑11 | Mineur | Cycle de vie | `lib/shared/widgets/nom_dialog.dart:15` | `TextEditingController` créé dans une fonction, **jamais `dispose()`**. Fuite par ouverture de dialogue. | Convertir en `StatefulWidget` avec `dispose`, ou `showDialog(...).whenComplete(controller.dispose)`. |
| BP‑12 | Mineur | Riverpod | `lib/shared/services/notification_providers.dart:15` | Effet de bord (`service.resynchroniser`) dans le `build` d'un `Provider`. | Utiliser `ref.listen` sur `instancesEnStockGlobalProvider`. |
| BP‑13 | Mineur | Performance | `courses_page.dart:32` (+ `gerer_catalogue_page`, `plat_detail_screen`) | `ListView(children: [...])` non-lazy sur des listes potentiellement longues. | `ListView.builder` / `.separated` pour la liste de courses. |
| BP‑14 | Mineur | Performance | `FrigoPage`, `PlanificationPage` | `ref.watch` de plusieurs providers au niveau du `Scaffold` → rebuild large à chaque changement de filtre. | Découper en sous-widgets `Consumer` ciblés. |
| BP‑04 | Info | Imports | `lib/` | 100 % d'imports relatifs (cohérent) mais non verrouillé par un lint. | Ajouter `prefer_relative_imports`. |
| BP‑09 | Info | Divulgation | (= SEC‑11) | `catch (e) → 'Erreur : $e'`. | cf. SEC‑11. |
| BP‑15 | Info | Doc | Accesseurs triviaux des repos (`getById`, `getAll`, `getRoot`, `marquerAchete`…) sans `///` | Faible valeur. Les modules critiques (règles métier, `NotificationService`, `date_utils`) sont déjà documentés. Les classes de schéma ont reçu un `///` pendant l'audit. | Optionnel : compléter au fil de l'eau. |
| BP‑16 | Info | Tests | `unite_repository` (0 %), `urgencePeremption` (0 %), `NotificationService` (17 %), UI (~0 %), aucun test d'intégration | | Prioriser : validation quantités (SEC‑03), `urgencePeremption`, `unite_repository`, un test de `RepasListTile` couvrant l'échec de `marquerFait` (BP‑06). |

### Config linter proposée

`analysis_options.yaml` actuel : `flutter_lints` nu, aucune règle custom. Proposition (voie médiane) —
voir le détail commenté en **Phase 3 §3.8** :

- `analyzer.language: strict-casts / strict-inference / strict-raw-types`
- `exclude: **/*.g.dart`
- lints ajoutés : `unawaited_futures`, `discarded_futures`, `avoid_dynamic_calls`,
  `cast_nullable_to_non_nullable`, `prefer_relative_imports`, `directives_ordering`,
  `require_trailing_commas`, `always_declare_return_types`, `use_key_in_widget_constructors`,
  `sized_box_for_whitespace`, `avoid_redundant_argument_values`, `sort_pub_dependencies`.

Alternative « clé en main » : remplacer `flutter_lints` par **`very_good_analysis`**
(nécessitera une passe de mise en conformité).
**À activer après** la passe `dart format` (BP‑03) pour éviter les diffs mélangés.

---

## 3. Incohérences / code non câblé (rappel Phase 1)

| Élément | Statut |
|---|---|
| Écran de **gestion du catalogue produits** (`archiver` / `desarchiver` / `supprimerDefinitivement` / `previewSuppressionCascade` / `watchAll`) | ✅ **Implémenté pendant l'audit** (`produit_form_sheet.dart` + onglet Produits dans `gerer_catalogue_page.dart`). Résout la majeure partie de §6.1 d'`ARCHITECTURE.md`. |
| `RepasPlanifieRepository.watchByDateRange` / `watchProchains` (variantes non-`Detail`) | Non référencées — à retirer ou couvrir. |
| `PlatRepository.watchIngredients` (Stream) | Non référencée (l'UI utilise `getIngredients`). |
| `CategorieRepository.getAll` / `ZoneRepository.getAll` / `UniteRepository.getAll` / `getByTypeGrandeur` | Non référencées. |
| `ArticleCourseRepository.watchAll` param `statut` | Toujours appelé sans argument. |
| `ProduitRepository.marquerUtilise` | Redondant (`create` fait déjà le `dateDerniereUtilisation`). |
| Couplage inter-features : `planification` / `courses` importent des providers **et** un fichier de page de `frigo` (`produitsActifsProvider`, `unitesProvider`, `quantiteInputFormatters`) | À déplacer en `shared/`. |
| Duplication : `formatQuantite` (1 public + 2 copies privées) ; formatage date `jj/MM/aaaa` à la main dans ~7 fichiers alors qu'`intl` est déjà là ; bloc `AsyncValue.when(loading/error)` répété ~20× | À factoriser. |

---

## 4. Plan d'action priorisé

### Lot A — Quick wins ✅ **appliqué** (branche `audit/lot-a-quick-wins`)

| Ordre | Action | Réf. | Commit |
|---|---|---|---|
| A1 | `dart format lib test` (36 fichiers, purement stylistique) | BP‑03 | `92389d9` |
| A2 | `print` → `dart:developer log()` dans `NotificationService` | SEC‑10 | `a171d80` |
| A3 | `analysis_options.yaml` renforcé (strict-casts + 13 lints) + conformité (3 fichiers) | BP‑04 | `b61cc4c` |
| A4 | `nom_dialog` : `whenComplete(controller.dispose)` | BP‑11 | `84fe14d` |
| A5 | Garde `mounted` avant les `setState` de `catch` (4 sites) | BP‑07 | `3002102` |
| A6 | `.fvmrc` (Flutter 3.44.8) + correction `Docs/PRE-LAUNCH-CHECKLIST.md` | SEC‑13/14 | `59f01e0` (+ Docs, hors dépôt) |
| A7 | garde `if (v != null)` au lieu de `v!` (`modifier_instance_sheet`) | BP‑02 | `dfae041` |

> `strict-inference` / `strict-raw-types` et `unawaited_futures` / `discarded_futures`
> ont été **volontairement écartés du Lot A** : ils nécessitent des correctifs de
> code (annotations de type explicites, gestion des futures fire-and-forget) →
> traités en Lot B (B4). `sort_pub_dependencies` écarté (conflit avec l'ordre
> conventionnel « deps SDK en tête »).

### Lot B — À faire avant la première release

| Ordre | Action | Réf. | Nature |
|---|---|---|---|
| B1 | `signingConfigs.release` + `key.properties` gitignoré | SEC‑07 | config Gradle |
| B2 | Documenter/scripter le build obfusqué (fait dans le `README`) + valider un vrai build release (notifications incluses) | SEC‑08, SEC‑09 | process |
| B3 | Décision explicite sur le chiffrement de la base (recommandé : rester en clair, décision tracée) | SEC‑01 | décision |
| B4 | `unawaited_futures` activé + `await`/`try-catch` sur les actions fire-and-forget de l'UII | BP‑06 | correctif ciblé, **diff à valider** |
| B5 | `onUpgrade` (même vide) + procédure de migration | SEC‑02 | correctif, **diff à valider** |
| B6 | Helper de validation quantité (`> 0 && isFinite`) + `CHECK` SQL | SEC‑03, SEC‑04 | correctif, **diff à valider** (change le schéma → migration) |
| B7 | `FlutterError.onError` / `PlatformDispatcher.onError` dans `main.dart` | BP‑10 | correctif, **diff à valider** |
| B8 | Tests : validation quantités, `urgencePeremption`, `unite_repository`, échec `marquerFait` | BP‑16 | tests |

### Lot C — Refactoring (à planifier, pas urgent)

| Action | Réf. | Effort |
|---|---|---|
| Sortir les providers « catalogue » (`produitsActifsProvider`, `unitesProvider`, `zonesProvider`…) de `features/frigo` vers `shared/` ou `data/` ; idem `quantiteInputFormatters`, `formatQuantite` | §3 | moyen |
| Factoriser le formatage de date via `intl` `DateFormat` (~7 fichiers) et un widget `AsyncValueView` pour le `when(loading/error)` (~20 sites) | §3 | moyen |
| Homogénéiser la hiérarchie d'exceptions (retirer `StateError`/`ArgumentError` du domaine) + `catch` uniforme dans les sheets | BP‑08 | moyen |
| Déplacer l'agrégation hors des `build()` (providers dérivés) ; `ListView.builder` ; découpe des gros `Scaffold` en `Consumer` ciblés | BP‑05, BP‑13, BP‑14 | moyen |
| Nettoyer les méthodes de repository non référencées (ou les couvrir si un écran est prévu) | §3 | faible |
| Envisager la migration `flutter_riverpod` 2 → 3 | Phase 0 | élevé |
| Config `release` iOS des notifications si iOS entre au périmètre | SEC‑06 | moyen |

---

## 5. Ce qui a été modifié pendant l'audit

| Commit | Contenu | Risque |
|---|---|---|
| `df7a05a` | `chore: initial commit` — snapshot avant audit | — |
| `bde7ab0` | `docs: ARCHITECTURE.md` | nul (doc) |
| `5cd7897` | `docs:` — `///` sur les 9 tables + 4 enums + `AppDatabase` ; `README.md` ; `AUDIT_REPORT.md` | nul (doc / commentaires) |
| `053a491` | `feat(frigo):` écran de gestion du catalogue produits (travail en cours de l'auteur, commité pendant l'audit) | fonctionnel — `analyze` + `test` verts |
| `9c08bd7` | `style(frigo):` contraste des puces de filtre (travail en cours de l'auteur) | visuel |
| `59f01e0` | `chore:` `.gitattributes` (LF) + `.fvmrc` + `.gitignore` renforcé | nul |
| `92389d9`…`dfae041` | **Lot A** — voir §4 (branche `audit/lot-a-quick-wins`) | faible, chaque commit vérifié `analyze` 0 / `test` 36/36 |

**Non appliqué** : lots B et C (correctifs nécessitant décision ou revue de diff).
Voir §4.
