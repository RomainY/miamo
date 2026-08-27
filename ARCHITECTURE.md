# Architecture — Miamo

> Document produit lors de la **Phase 1** de l'audit (cartographie). Décrit
> l'état réel du code au commit initial, pas la cible.
> Références croisées : `../Docs/documentation-technique.md`,
> `../Docs/cahier-des-charges.md`.
>
> **Mise à jour (Phase 4)** : l'écran de gestion du catalogue produits, signalé
> comme manquant en §6.1, a été implémenté pendant l'audit
> (`produit_form_sheet.dart` + onglet « Produits » de `gerer_catalogue_page.dart`,
> `produitsTousProvider`). Les mentions « aucun appel dans `lib/` » des §6.1/§6.2
> concernant `archiver` / `desarchiver` / `supprimerDefinitivement` /
> `previewSuppressionCascade` / `watchAll` ne sont donc plus d'actualité.

---

## 1. Vue d'ensemble

| Aspect | Choix |
|---|---|
| Type d'app | Application mobile **100 % locale / offline** (frigo, planification des repas, liste de courses) |
| Framework | Flutter 3.44.8 / Dart 3.12.2 |
| Gestion d'état | **Riverpod** (`flutter_riverpod` 2.6.1), providers écrits à la main (pas de `riverpod_generator`) |
| Persistance | **SQLite** via **Drift** (`drift` + `drift_flutter`), une seule base fichier `app_frigo` |
| Réseau | **Aucun** — pas d'API, pas de backend, pas d'authentification (choix structurel, `documentation-technique.md §1` & `§5`) |
| Plateformes générées | Android, iOS, Web, Windows. Cible réelle du MVP : Android (`minSdk 24`) |
| Plugin natif | `flutter_local_notifications` (+ `flutter_timezone`, `timezone`) — notifications locales de péremption |
| i18n | Français uniquement (`locale: fr`, `flutter_localizations`, `intl` pour le formatage de dates) |

---

## 2. Structure des dossiers et responsabilités des couches

```
lib/
├── main.dart                     Bootstrap : ensureInitialized, initializeDateFormatting('fr_FR'),
│                                 runApp(ProviderScope(App()))
│
├── app/
│   └── app.dart                  MaterialApp (thème, locale) + _RootShell :
│                                 Scaffold à 3 onglets (NavigationBar), state local `_index`.
│                                 Point d'ancrage du notificationSyncProvider.
│
├── data/                         ── COUCHE DONNÉES (partagée par toutes les features) ──
│   ├── database/
│   │   ├── tables.dart           9 tables Drift + 6 enums métier. Schéma, contraintes
│   │   │                         (UNIQUE, withLength, références FK), @DataClassName.
│   │   ├── app_database.dart     @DriftDatabase, schemaVersion = 1, MigrationStrategy
│   │   │                         (onCreate → createAll + seed ; beforeOpen → PRAGMA
│   │   │                         foreign_keys = ON). _openConnection = driftDatabase(name:).
│   │   ├── app_database.g.dart   Généré par drift_dev (build_runner). Commité.
│   │   ├── seeders.dart          seedInitialData() : catégorie « Non classé », zone racine
│   │   │                         « Frigo », 7 unités de base.
│   │   └── database_provider.dart  appDatabaseProvider (Provider<AppDatabase>, ferme la
│   │                              base via ref.onDispose).
│   └── repositories/
│       ├── base_repository.dart          BaseRepository abstrait : porte `AppDatabase db`,
│       │                                 aucune logique.
│       ├── categorie_repository.dart     CRUD + réaffectation vers « Non classé ».
│       ├── zone_repository.dart          CRUD + réaffectation vers zone racine.
│       ├── unite_repository.dart         Lecture seule du référentiel d'unités.
│       ├── produit_repository.dart       Catalogue produits + cycle de vie
│       │                                 (archiver/désarchiver/suppression cascade +
│       │                                 CascadeSuppressionProduit).
│       ├── produit_frigo_repository.dart Instances physiques. watchEnStock (join produit/
│       │                                 unité/zone → InstanceFrigoDetail), tri par urgence.
│       ├── plat_repository.dart          Plats + ingrédients (IngredientInput / IngredientDetail),
│       │                                 remplacement complet des ingrédients.
│       ├── repas_planifie_repository.dart Planification + `marquerFait` = décompte FIFO du
│       │                                 frigo avec conversion d'unités.
│       ├── article_course_repository.dart Liste de courses (ajout manuel) + renvoyerVersFrigo.
│       └── repository_providers.dart     8 Provider<XxxRepository>, chacun câblé sur
│                                         appDatabaseProvider.
│
├── features/                     ── COUCHE PRÉSENTATION (une sous-arbo par feature) ──
│   ├── frigo/presentation/
│   │   ├── pages/                frigo_page, ajouter_produit_sheet, modifier_instance_sheet,
│   │   │                         gerer_catalogue_page (produits + catégories + zones),
│   │   │                         produit_form_sheet (créer/modifier un Produit)
│   │   ├── providers/            frigo_providers.dart : filtres (StateProvider), StreamProviders
│   │   │                         (instances, catégories, zones, unités, produits actifs,
│   │   │                         produitsTousProvider pour l'écran catalogue)
│   │   └── widgets/              category_chips_bar, expiration_warning_banner,
│   │                             product_list_tile, urgence_indicator
│   ├── planification/presentation/
│   │   ├── pages/                planification_page, plats_page, plat_detail_screen,
│   │   │                         planifier_repas_sheet, ajouter_ingredient_sheet
│   │   ├── providers/            planification_providers.dart : date sélectionnée + vue
│   │   │                         (StateProvider), plats / repas du mois / prochains repas
│   │   └── widgets/              calendar_view (table_calendar), day_planning_list,
│   │                             repas_list_tile
│   └── courses/presentation/
│       ├── pages/                courses_page, ajouter_article_sheet, renvoyer_vers_frigo_sheet
│       ├── providers/            courses_providers.dart : articlesCourseProvider
│       └── widgets/              article_course_tile
│
└── shared/                       ── TRANSVERSE ──
    ├── services/
    │   ├── notification_service.dart    Wrapper FlutterLocalNotificationsPlugin :
    │   │                                init lazy, demande de permission, resynchroniser()
    │   │                                = cancelAll + zonedSchedule par instance.
    │   └── notification_providers.dart  notificationServiceProvider +
    │                                    notificationSyncProvider (effet de bord réactif).
    ├── theme/app_theme.dart      AppColors, AppRadius, buildAppTheme() (Material 3, police
    │                             Quicksand bundlée).
    ├── utils/
    │   ├── constants.dart        Seuils péremption (joursAvantNotification=2, heureNotification=9,
    │   │                         seuilAlerteBandeauJours=3).
    │   ├── date_utils.dart       Logique pure : dateDeclenchementNotification, joursRestants,
    │   │                         urgencePeremption (label + couleur).
    │   └── exceptions.dart       5 exceptions métier (message prêt à afficher).
    └── widgets/nom_dialog.dart   Dialogue générique de saisie de nom (catégorie/zone).
```

### Couches (de haut en bas)

1. **Présentation** (`features/*/presentation`, `app/`, `shared/widgets`, `shared/theme`)
   Widgets (`ConsumerWidget` / `ConsumerStatefulWidget`), sheets modales, dialogues.
   Consomme des providers, appelle directement les méthodes des repositories.
2. **État applicatif** (`features/*/presentation/providers`, `shared/services/notification_providers`)
   Providers Riverpod : `StateProvider` pour l'état d'écran (filtres, date, vue),
   `StreamProvider` (souvent `.family`) pour les données réactives issues des `watch*` Drift.
3. **Accès aux données / logique métier** (`data/repositories`)
   Toute la logique de règles (conversion d'unités, FIFO de décompte, cascades de
   suppression, protections zone racine / catégorie par défaut, unicité des noms) vit ici.
4. **Persistance** (`data/database`)
   Schéma Drift, migrations, seed, connexion SQLite.

> ⚠️ **Il n'y a pas de couche `domain` / `use case`** ni d'entités séparées :
> les DataClasses générées par Drift (`Categorie`, `ProduitFrigo`, …) sont utilisées
> directement dans l'UI. Choix cohérent avec `documentation-technique.md §4`, qui ne
> prévoit que « 3 features + une couche repository partagée ».

---

## 3. Flux de données principal

### 3.1 Lecture (réactif, « live »)

```
SQLite (fichier app_frigo)
   ▲
   │  drift : SELECT … .watch()  → Stream<List<Row>>
   │
data/repositories/XxxRepository.watchYyy()
   │  (join + map vers un DTO d'affichage : InstanceFrigoDetail,
   │   RepasPlanifieDetail, ArticleCourseDetail, IngredientDetail)
   ▼
features/…/providers  (StreamProvider / StreamProvider.family)
   │  recompose selon les StateProvider de filtre (zone, catégorie, date, vue)
   ▼
Widget  ref.watch(provider)  →  AsyncValue.when(data/loading/error)
```

Exemple concret (écran Frigo) :
`frigoFiltreZoneProvider` + `frigoFiltreCategorieProvider` (StateProvider)
→ `instancesEnStockProvider` (StreamProvider) → `produitFrigoRepository.watchEnStock(zoneId, categorieId)`
→ requête Drift jointe triée par urgence → `List<InstanceFrigoDetail>` → `FrigoPage` → `ProductListTile`.

### 3.2 Écriture (impératif)

```
Widget (sheet / dialog / menu)  ──►  ref.read(xxxRepositoryProvider).methode(...)
                                        │
                                        ▼
                     data/repositories : validations métier + db.transaction { … }
                                        │
                                        ▼
                                    SQLite  ──►  émet sur les Streams watch()
                                        │
                                        ▼
              les StreamProviders concernés se rafraîchissent  ──►  UI à jour
```

- Les écritures ne passent **pas** par un provider dédié : le widget récupère le
  repository via `ref.read(...)` et appelle la méthode directement (`create`, `update`,
  `marquerConsomme`, `planifier`, `marquerFait`, …).
- Les opérations multi-tables sont encapsulées dans `db.transaction(...)`
  (ex. `ProduitRepository.supprimerDefinitivement`, `RepasPlanifieRepository.marquerFait`,
  `ArticleCourseRepository.renvoyerVersFrigo`, réaffectations catégorie/zone).
- Les erreurs métier remontent sous forme d'exceptions typées (`exceptions.dart`) que
  l'UI attrape sélectivement (`on DuplicateNameException`, `on ReferenceActiveException`,
  `on ElementProtegeException`, …) pour afficher `e.message`.

### 3.3 Effet de bord : notifications

```
instancesEnStockGlobalProvider (StreamProvider, sans filtre)
        │
        ▼
notificationSyncProvider (Provider<void>)  ──  watché une fois dans _RootShell
        │   instances.whenData((liste) => notificationService.resynchroniser(liste))
        ▼
NotificationService.resynchroniser :
   _assurerInitialisation() (tz + permission POST_NOTIFICATIONS)
   → plugin.cancelAll()
   → pour chaque instance avec datePeremption :
        date_utils.dateDeclenchementNotification (J-2 à 9 h, null si passé)
        → plugin.zonedSchedule(id = instance.id, …)
```

Stratégie « tout annuler puis reprogrammer » à chaque changement du frigo :
simple et auto-réparatrice, acceptable vu le volume (dizaines d'instances).

---

## 4. Patterns utilisés et cohérence

| Pattern | Mise en œuvre | Cohérence |
|---|---|---|
| **Repository** | 8 repositories `extends BaseRepository`, un par agrégat métier. Méthodes `watch*` (Stream) / `get*` (Future) / mutations. | ✅ Homogène. Nommage FR cohérent (`create`, `update`, `delete`, `marquerXxx`, `watchXxx`). |
| **DI / Service Locator** | Riverpod. `appDatabaseProvider` → 8 `xxxRepositoryProvider` → providers de feature. Override en test via `ProviderContainer(overrides:)`. | ✅ Chaîne claire, testable. |
| **DTO d'affichage** | `InstanceFrigoDetail`, `RepasPlanifieDetail`, `ArticleCourseDetail`, `IngredientDetail` : agrègent la ligne + ses entités liées en une passe (join), pour éviter le N+1 côté UI. | ✅ Bon réflexe perf. |
| **Value objects d'entrée** | `IngredientInput`, `IngredientChoisi`, `_IngredientEdit`, `CascadeSuppressionProduit`. | ⚠️ `_IngredientEdit` (plat_detail) et `IngredientChoisi` (sheet) et `IngredientInput` (repo) sont trois structures quasi identiques — voir §6. |
| **Unit of Work / Transaction** | `db.transaction { … }` pour toute mutation multi-tables. | ✅ Systématique. |
| **Exceptions métier typées** | `exceptions.dart`, message utilisateur porté par l'exception. | ✅ Cohérent, mais capture partielle côté UI (voir §6). |
| **State management d'écran** | `StateProvider` pour filtres/sélection globale ; `setState` local pour l'état de formulaire des sheets et `_moisAffiche` / `_index`. | ⚠️ Mixte assumé mais non documenté ; `_moisAffiche` (mois du calendrier) est en `setState` alors que la date sélectionnée est en provider. |
| **Logique pure isolée** | `date_utils.dart` sans dépendance plugin/timezone → testé unitairement. | ✅ Très bon découpage. |
| **Feature-first** | `features/<feature>/presentation/{pages,providers,widgets}`. | ⚠️ Seul le niveau `presentation` existe (pas de `domain`/`data` par feature) — l'arborescence suggère une Clean Archi qui n'est pas là. Cohérent avec la doc, mais peut induire en erreur. |

### Cohérence inter-features
- Les trois features réutilisent `produitsActifsProvider` et `unitesProvider` **définis dans
  `frigo/presentation/providers`**. `planification` et `courses` importent donc des providers
  de `frigo` (couplage inter-features). Voir §6.
- `formatQuantite` est défini dans `frigo/.../product_list_tile.dart` et importé par
  `courses/.../article_course_tile.dart` ; une 2ᵉ copie privée existe dans
  `modifier_instance_sheet.dart` et `plat_detail_screen.dart`.
- `quantiteInputFormatters` est défini dans `frigo/.../ajouter_produit_sheet.dart` et
  importé par 3 autres sheets (planification + courses).

---

## 5. Points d'entrée sensibles

### 5.1 Réseau
- **Aucun appel réseau applicatif.** Pas de `http`, `dio`, `WebSocket`, `HttpClient` dans `lib/`.
- `timezone` embarque `http` en dépendance transitive mais seule la base de données de
  fuseaux **bundlée** est utilisée (`timezone/data/latest.dart`) — pas de fetch runtime.
- Manifests `debug`/`profile` déclarent `INTERNET` (injecté par l'outillage Flutter pour le
  hot-reload) ; le manifest `main` (release) **ne le déclare pas**. ✅

### 5.2 Stockage local
- **Une base SQLite** : `driftDatabase(name: 'app_frigo')` → fichier dans le répertoire
  documents de l'app (via `drift_flutter` + `path_provider`).
- **Non chiffrée.** `drift_flutter` tire `sqlcipher_flutter_libs` mais aucune clé/PRAGMA key
  n'est passée → base en clair. (À traiter en Phase 2 : données non critiques, mais point à trancher.)
- `PRAGMA foreign_keys = ON` activé à chaque ouverture (`beforeOpen`). ✅
- **Pas de `SharedPreferences`, pas de `flutter_secure_storage`, pas de fichiers écrits
  ailleurs.** Aucun secret, credential ou token (app sans compte).
- `schemaVersion = 1`, `onUpgrade` non défini : **aucune stratégie de migration** au-delà de
  la création initiale (acceptable tant que le schéma n'a pas bougé après une première release,
  à surveiller).

### 5.3 Permissions système
| Permission | Déclarée dans | Utilisée par | Justifiée ? |
|---|---|---|---|
| `POST_NOTIFICATIONS` | `AndroidManifest.xml` (main) | `NotificationService` (`requestNotificationsPermission`) | ✅ oui |
| `RECEIVE_BOOT_COMPLETED` | `AndroidManifest.xml` (main) | reprogrammation des notifications après reboot (`flutter_local_notifications`) | ✅ oui |
| `INTERNET` | manifests `debug` + `profile` uniquement | outillage Flutter (hot reload) | ✅ dev only |
- **iOS** : `Info.plist` ne déclare **aucune** `UNUserNotificationCenter` / `UIBackgroundModes`
  ni `NSUserNotificationsUsageDescription`. Les notifications locales iOS ne sont pas
  configurées (initialisation `InitializationSettings(android: …)` seulement) → **iOS non
  couvert** pour la feature notification. À noter si iOS entre dans le périmètre.
- Pas de permission caméra, localisation, contacts, stockage externe, etc.

### 5.4 Deep links
- **Aucun.** Le seul `intent-filter` est `MAIN` / `LAUNCHER`. Pas de `data android:scheme`,
  pas de App Links / Universal Links, pas de package `uni_links` / `app_links` / `go_router`.
- Navigation 100 % impérative via `Navigator.of(context).push(MaterialPageRoute(...))` ; pas
  de routeur nommé, pas de table de routes.
- `<queries>` `PROCESS_TEXT` : bloc standard généré par `flutter create`, non exploité.

### 5.5 Plateformes natives / platform channels
- **Aucun `MethodChannel` / `EventChannel` custom**, aucun code Kotlin/Swift applicatif
  (`MainActivity.kt` = stub `FlutterActivity` par défaut).
- Canaux natifs uniquement via plugins tiers : `flutter_local_notifications`,
  `flutter_timezone`, `path_provider`, `sqlite3_flutter_libs` / `sqlcipher_flutter_libs`
  (natif SQLite embarqué).
- `flutter_launcher_icons` / `flutter_native_splash` : outils de build, pas de runtime.
- Desugaring Java 8+ activé (`isCoreLibraryDesugaringEnabled = true`) pour
  `flutter_local_notifications` ; `minSdk 24`, `multiDexEnabled = true`.

### 5.6 Entrées utilisateur (surface de validation)
- Champs de quantité : `FilteringTextInputFormatter.allow([0-9.,])` puis
  `double.tryParse(replaceAll(',', '.'))`. Pas de borne haute, accepte `1..2` / `1,,` →
  `tryParse` renvoie `null` et le bouton reste désactivé (garde-fou en place mais implicite).
- Noms (catégorie, zone, produit, plat) : `trim()` + `isNotEmpty` côté UI, `withLength`
  côté schéma, unicité vérifiée en repository. Pas de nettoyage HTML/SQL nécessaire (Drift =
  requêtes paramétrées, voir Phase 2).
- Dates : `showDatePicker` borné (`firstDate` / `lastDate`), pas de saisie libre.

---

## 6. Incohérences architecturales & code mort

### 6.1 Data layer en avance sur l'UI (fonctionnel, non « mort », mais non câblé)

> ✅ **Résolu en Phase 4** : `archiver` / `desarchiver` / `supprimerDefinitivement` /
> `previewSuppressionCascade` + `CascadeSuppressionProduit` et
> `ProduitRepository.watchAll({categorieId})` (via `produitsTousProvider`) sont
> désormais câblés dans l'onglet « Produits » de `gerer_catalogue_page.dart` +
> `produit_form_sheet.dart`.

| Élément | État | Remarque |
|---|---|---|
| `ProduitRepository.marquerUtilise` | non utilisé dans `lib/` | `create` et `produitFrigo.create` mettent déjà `dateDerniereUtilisation` à jour eux-mêmes ; méthode redondante (chemin A « produit existant sélectionné » ne l'appelle jamais). |

### 6.2 Code non référencé (candidats à suppression ou à couvrir)
| Symbole | Fichier | Usage |
|---|---|---|
| `RepasPlanifieRepository.watchByDateRange` (variante non-`Detail`) | `repas_planifie_repository.dart:32` | aucun (ni `lib/` ni `test/`) |
| `RepasPlanifieRepository.watchProchains` (variante non-`Detail`) | `repas_planifie_repository.dart:39` | aucun |
| `PlatRepository.watchIngredients` (variante Stream) | `plat_repository.dart:49` | aucun — l'UI utilise `getIngredients` (Future) |
| `CategorieRepository.getAll` / `ZoneRepository.getAll` / `UniteRepository.getAll` | resp. `:21` / `:21` / `:19` | aucun — l'UI passe par les `watchAll` ou `getByTypeGrandeur` |
| `UniteRepository.getByTypeGrandeur` | `unite_repository.dart:25` | aucun dans `lib/` (le filtrage par grandeur est refait à la main dans `ajouter_produit_sheet` et `produit_form_sheet`) |
| `ArticleCourseRepository.watchAll` param `statut` | `article_course_repository.dart:25` | toujours appelé sans argument (le tri à acheter / acheté est refait dans `courses_page`) |
| `UrgencePeremption` branche « date formatée » (`> 7 j`) | `date_utils.dart:57` | atteignable, mais `watchEnStock` n'affiche que le stock ; OK |

> Aucune de ces méthodes n'est vraiment nuisible ; ce sont des surfaces d'API prévues
> pour des écrans à venir. À arbitrer : les garder (avec `// ignore: unused_element` ? non,
> ce sont des membres publics) ou les retirer jusqu'à ce que l'écran consommateur arrive.

### 6.3 Couplage inter-features
- `planification` et `courses` importent des **providers de `frigo`** :
  `produitsActifsProvider`, `unitesProvider`, `zonesProvider`, `frigoFiltreCategorieProvider`.
  Ces providers sont transverses (catalogue) et devraient vivre dans
  `data/repositories` ou un `shared/providers`, pas sous `features/frigo`.
- `courses/.../renvoyer_vers_frigo_sheet` et `planification/.../ajouter_ingredient_sheet`
  importent `frigo/presentation/pages/ajouter_produit_sheet.dart` juste pour
  `quantiteInputFormatters` → devrait être dans `shared/utils`.
- `article_course_tile` importe `formatQuantite` depuis `frigo/.../product_list_tile.dart`.

### 6.4 Duplication
- **`formatQuantite`** : 1 version publique (`product_list_tile.dart`) + 2 copies privées
  identiques (`modifier_instance_sheet.dart:50`, `plat_detail_screen.dart:216`).
- **Formatage de date `jj/MM/aaaa`** réécrit à la main (`padLeft`) dans au moins 6 fichiers
  (`ajouter_produit_sheet`, `modifier_instance_sheet`, `planifier_repas_sheet`,
  `renvoyer_vers_frigo_sheet`, `repas_list_tile`, `date_utils`, `notification_service`) —
  alors qu'`intl` (`DateFormat`) est déjà une dépendance.
- **Structures d'ingrédient** : `IngredientInput` (repo) / `IngredientChoisi` (sheet) /
  `_IngredientEdit` (écran plat) portent les mêmes champs `produitId, quantite, uniteId (+nom)`.
- **Bloc `AsyncValue.when(loading: CircularProgressIndicator, error: Text('Erreur : $e'))`**
  répété ~20 fois — candidat à un widget helper.

### 6.5 Incohérences de gestion d'erreur (détail Phase 3, listé ici pour mémoire)
- `NotificationService.resynchroniser` avale toute exception dans un `print` (`// ignore:
  avoid_print`) — seule entorse au `avoid_print`, et log en clair en prod.
- `planifier_repas_sheet._valider` et plusieurs sheets font un `catch (e)` générique qui
  affiche `Erreur : $e` (fuite de détails techniques dans l'UI).
- `modifier_instance_sheet._valider` / `ajouter_article_sheet._valider` : `double.tryParse`
  qui renvoie `null` provoque un `return` **silencieux** (aucun retour visuel).

### 6.6 Points de robustesse schéma
- `RepasPlanifie` : contrainte « exactement un de `platId` / `produitId` » portée **seulement
  par le code** (`planifier` lève `ArgumentError`), pas par une contrainte CHECK SQL.
- `ProduitFrigo` n'a pas d'index sur `produitId` / `statut` / `zoneId` alors que `watchEnStock`
  et `_decrementerStock` filtrent dessus (volume faible attendu → non bloquant).
- `schemaVersion = 1` sans `onUpgrade` : première migration future à ne pas oublier.

---

## 7. Schéma de données (résumé)

```
categorie (id, nom¹, icone, estParDefaut)          zone (id, nom¹, icone, isRoot)
    ▲                                                   ▲
    │ categorieId                                       │ zoneId
produit (id, nom¹, categorieId→categorie,          produit_frigo (id, produitId→produit,
         typeGrandeur, uniteDefautId→unite,             zoneId→zone, quantite, uniteId→unite,
         statut{actif|archive}, dateDerniereUtilisation)  dateAjout, datePeremption?,
    ▲         ▲          ▲                                 statut{enStock|consomme|jete}, dateStatut?)
    │         │          │
    │         │          └──── plat_ingredient (id, platId→plat, produitId→produit,
    │         │                                  quantite, uniteId→unite)
    │         │                     ▲
    │         │                     │ platId
    │         └──── repas_planifie (id, date, platId?→plat, produitId?→produit,
    │                               portions, statut{planifie|fait|annule})
    │
    └──── article_course (id, produitId→produit, quantite, uniteId→unite,
                          origine{manuel|suggestionRupture|suggestionPlanification},
                          statut{aAcheter|achete})

unite (id, nom¹, typeGrandeur{masse|volume|unite}, facteurVersBase)
¹ = contrainte UNIQUE
```

---

## 8. Tests (état des lieux)

| Type | Emplacement | Portée |
|---|---|---|
| Unitaires repositories | `test/unit/repositories/*` (8 fichiers, base `NativeDatabase.memory()`) | catégorie, zone, produit, produit_frigo, plat, repas_planifié, article_course — règles métier, cascades, protections, tri par urgence, décompte FIFO. |
| Unitaires utils | `test/unit/utils/date_utils_test.dart` | déclenchement notification, `joursRestants`. |
| Widget | `test/widget_test.dart` | démarrage de l'app, présence des 3 onglets (base en mémoire injectée). |
| Intégration | — | **absent**. |

`flutter analyze` : 0 issue. `flutter test` : **36/36 vert**.
Zones non couvertes : `NotificationService`, tous les widgets/sheets, `app_theme`,
providers Riverpod (composition des filtres).
