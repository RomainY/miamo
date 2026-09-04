# Miamo

Application mobile **offline-first** de gestion du frigo, de planification des
repas et de liste de courses.

- Pas de compte, pas de backend, pas de synchronisation : toutes les données
  vivent dans une base SQLite sur l'appareil.
- Pleinement utilisable sans réseau. Un seul appel sortant facultatif existe
  (enrichissement d'un produit scanné via [Open Food
  Facts](https://world.openfoodfacts.org)), déclenché uniquement sur action
  utilisateur et après consentement explicite (réglage réversible).

Cible principale : Android. iOS / Web / Windows sont générés par le template mais
non validés (les notifications ne sont configurées que pour Android).

---

## Stack

| Domaine | Choix |
|---|---|
| Framework | Flutter (canal stable) / Dart |
| Gestion d'état | [Riverpod](https://riverpod.dev) (`flutter_riverpod`, providers écrits à la main) |
| Persistance | SQLite via [Drift](https://drift.simonbinder.eu) (`drift` + `drift_flutter`) |
| Notifications | `flutter_local_notifications` + `timezone` + `flutter_timezone` (péremption) |
| Calendrier | `table_calendar` |
| Scan code-barres | `mobile_scanner` (local) + `http` (Open Food Facts, best-effort) |
| i18n | Français uniquement (`flutter_localizations`, `intl`) |

Versions de référence (voir aussi la section *Environnement*) : Flutter 3.44.8 /
Dart 3.12.x — épinglées dans [`.fvmrc`](.fvmrc).

---

## Démarrage rapide

```bash
# 1. Récupérer les dépendances
flutter pub get

# 2. Générer le code Drift (app_database.g.dart)
dart run build_runner build --delete-conflicting-outputs

# 3. Lancer sur un appareil / émulateur Android
flutter run
```

### Pré-requis

- Flutter SDK installé (`flutter doctor` au vert pour Android) — voir
  [`.fvmrc`](.fvmrc) pour la version pinnée ; utiliser [FVM](https://fvm.app)
  ou un SDK système de la même version.
- Un émulateur Android ou un appareil physique en mode développeur.
- Aucune clé d'API, aucun fichier `.env`, aucune variable d'environnement :
  Open Food Facts est appelé anonymement (code-barres uniquement, pas de clé).

---

## Commandes utiles

| But | Commande |
|---|---|
| Analyse statique | `flutter analyze` |
| Formatage (vérif.) | `dart format --output=none --set-exit-if-changed lib test` |
| Formatage (appliquer) | `dart format lib test` |
| Tests + couverture | `flutter test --coverage` |
| Régénérer le code Drift | `dart run build_runner build --delete-conflicting-outputs` |
| Régénérer en continu | `dart run build_runner watch --delete-conflicting-outputs` |
| Régénérer icône + splash | `dart run flutter_launcher_icons` puis `dart run flutter_native_splash:create` |

### Build de production (Android)

> ⚠️ **À faire avant toute distribution** : le build `release` est actuellement
> signé avec la **clé de debug** (`android/app/build.gradle.kts`). Créer un
> `android/key.properties` (non versionné) et un `signingConfigs.release` selon
> la [doc Flutter](https://docs.flutter.dev/deployment/android#signing-the-app).

```bash
# App bundle release, code Dart obfusqué + symboles séparés
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols
```

Conserver le dossier `build/symbols/` hors dépôt pour désymboliser les stack
traces (`flutter symbolize`).

---

## Architecture en un coup d'œil

```
lib/
├── main.dart              Bootstrap (init i18n fr, ProviderScope)
├── app/                   MaterialApp + shell 3 onglets (Frigo / Planif / Courses)
├── data/
│   ├── database/          Drift : tables, base, migrations, seed
│   └── repositories/      Toute la logique métier (1 repo par agrégat)
├── features/
│   ├── frigo/ planification/ courses/
│   │   └── presentation/{pages,providers,widgets}
└── shared/
    ├── services/          NotificationService (péremption)
    ├── theme/  utils/  widgets/
```

Flux : **UI (`features`) → providers Riverpod → repositories (`data`) → SQLite**.
Lecture réactive via les `Stream` de Drift exposés en `StreamProvider` ; écriture
impérative via `ref.read(xxxRepositoryProvider).methode(...)`, transactions dans
les repositories.

Détail complet : [`ARCHITECTURE.md`](ARCHITECTURE.md).
Audit qualité / sécurité : [`AUDIT_REPORT.md`](AUDIT_REPORT.md).
Roadmap post-MVP : [`../Docs/specs-app-frigo.md`](../Docs/specs-app-frigo.md#4-roadmap--fonctionnalités-et-style-à-venir-post-mvp)
(prochain chantier : auto-génération de la liste de courses à partir des
produits périmés/épuisés et des ingrédients manquants des plats planifiés).

### Modèle de données (10 tables)

`categorie`, `zone`, `unite`, `produit`, `produit_frigo`, `plat`,
`plat_ingredient`, `repas_planifie`, `reglage`, `article_course`.

Le schéma est en **version 4** (migrations couvertes par `SchemaVerifier`,
snapshots dans `drift_schemas/`). Au premier lancement, un *seed* crée la zone
racine « Frigo », les unités de base et un jeu de catégories courantes (dont
les noms correspondent aux buckets Open Food Facts, pour une
pré-sélection directe des produits scannés).

Spécifications fonctionnelles et techniques détaillées : dossier `../Docs/`
(`cahier-des-charges.md`, `documentation-technique.md`).

---

## Tests

- Unitaires : `test/unit/repositories/` (base `NativeDatabase.memory()`),
  `test/unit/domain/`, `test/unit/services/`, `test/unit/utils/` et
  `test/unit/database/` (migrations, via `SchemaVerifier`).
- Widget : `test/widget/` + `test/widget_test.dart` (démarrage de l'app).
- Lancer : `flutter test` (ou `flutter test --coverage` puis ouvrir
  `coverage/lcov.info`). 123 tests verts au dernier commit.

---

## Environnement

Version de Flutter épinglée dans [`.fvmrc`](.fvmrc) (actuellement 3.44.8), pour
des builds reproductibles. Utiliser [FVM](https://fvm.app) (`fvm flutter ...`)
ou un SDK système de la même version — le SDK local n'est pas versionné
(`.fvm/` est ignoré).
