# Miamo

Application mobile **100 % locale / hors-ligne** de gestion du frigo, de
planification des repas et de liste de courses.

- Pas de compte, pas de backend, pas d'appel réseau, pas de synchronisation.
- Toutes les données vivent dans une base SQLite sur l'appareil.

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
| i18n | Français uniquement (`flutter_localizations`, `intl`) |

Versions de référence (voir aussi la section *Environnement*) : Flutter 3.44.x /
Dart 3.12.x.

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

- Flutter SDK installé (`flutter doctor` au vert pour Android).
- Un émulateur Android ou un appareil physique en mode développeur.
- Aucune clé d'API, aucun fichier `.env`, aucune variable d'environnement :
  l'application ne dépend d'aucun service externe.

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

### Modèle de données (9 tables)

`categorie`, `zone`, `unite`, `produit`, `produit_frigo`, `plat`,
`plat_ingredient`, `repas_planifie`, `article_course`.

Le schéma est en **version 1**. Au premier lancement, un *seed* crée la
catégorie « Non classé », la zone racine « Frigo » et les unités de base.

Spécifications fonctionnelles et techniques détaillées : dossier `../Docs/`
(`cahier-des-charges.md`, `documentation-technique.md`).

---

## Tests

- Unitaires : `test/unit/repositories/` (base `NativeDatabase.memory()`) +
  `test/unit/utils/`.
- Widget : `test/widget_test.dart` (démarrage de l'app).
- Lancer : `flutter test` (ou `flutter test --coverage` puis ouvrir
  `coverage/lcov.info`).

---

## Environnement

La version de Flutter n'est pas encore épinglée. Recommandé : ajouter un
`.fvmrc` ([FVM](https://fvm.app)) ou documenter ici la version exacte utilisée
par l'équipe, pour des builds reproductibles.
