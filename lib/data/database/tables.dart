import 'package:drift/drift.dart';

// ─── Enums métier (cf. documentation-technique.md §2) ──────────────────────

/// Grandeur physique d'une unité / d'un produit. On ne compare ou n'additionne
/// jamais deux quantités de type_grandeur différents.
enum TypeGrandeur { masse, volume, unite }

/// Cycle de vie d'un [Produits] du catalogue. Un produit `archive` n'est plus
/// proposé pour de nouveaux usages mais reste référencé par ses usages passés
/// (cf. documentation-technique.md §3 "Cycle de vie d'un Produit du catalogue").
enum StatutProduit { actif, archive }

/// État d'une instance physique [ProduitsFrigo]. `consomme` / `jete` alimentent
/// les statistiques anti-gaspi (via `dateStatut`) ; une suppression de ligne
/// directe, elle, ne les alimente pas.
enum StatutProduitFrigo { enStock, consomme, jete }

/// État d'un [RepasPlanifies]. Le décompte du frigo n'a lieu qu'au passage à
/// `fait` (cf. documentation-technique.md §3 "Décompte réel du frigo").
enum StatutRepas { planifie, fait, annule }

/// MVP v1 : seule `manuel` est utilisée. Les deux autres sont réservées à
/// l'auto-génération v1.1+ (cf. cahier-des-charges.md §3.3).
enum OrigineArticle { manuel, suggestionRupture, suggestionPlanification }

/// État d'un [ArticlesCourse] dans la liste de courses.
enum StatutArticle { aAcheter, achete }

// ─── Tables ──────────────────────────────────────────────────────────────
//
// Chaque table porte un @DataClassName singulier français (ex. Categories ->
// Categorie) pour coller au vocabulaire du cahier des charges, tandis que le
// nom de table SQL reste explicite via `tableName`.

/// Catalogue des catégories de produits (Frais, Épicerie…). CRUD complet côté
/// utilisateur ; `nom` unique. Voir documentation-technique.md §2 "Categorie".
@DataClassName('Categorie')
class Categories extends Table {
  @override
  String get tableName => 'categorie';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withLength(min: 1, max: 100)();
  TextColumn get icone => text().withDefault(const Constant('category'))();

  /// Catégorie "Non classé" (seed initial) : non supprimable, cible de
  /// réaffectation automatique. Absent du schéma documenté tel quel ; ajouté
  /// ici par symétrie avec `Zone.is_root` pour ne pas dépendre du nom
  /// (qui reste modifiable, cf. cahier-des-charges.md §8.2 pour le pattern
  /// équivalent sur Zone).
  BoolColumn get estParDefaut => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {nom},
  ];
}

/// Emplacements de stockage (Frigo, Congélateur, Placard…). CRUD complet ;
/// `nom` unique. La zone `isRoot` est la cible de réaffectation et n'est jamais
/// supprimable. Voir documentation-technique.md §2 "Zone".
@DataClassName('Zone')
class Zones extends Table {
  @override
  String get tableName => 'zone';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withLength(min: 1, max: 100)();
  TextColumn get icone => text().withDefault(const Constant('kitchen'))();

  /// Zone racine "Frigo" (seed initial) : modifiable mais non supprimable,
  /// cible de réaffectation. Cf. cahier-des-charges.md §8.2.
  BoolColumn get isRoot => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {nom},
  ];
}

/// Référentiel d'unités de mesure (gramme, litre, pièce…), seedé au premier
/// lancement. `facteurVersBase` convertit vers l'unité de base du `typeGrandeur`
/// pour toute comparaison de quantités. Voir documentation-technique.md §2.
@DataClassName('Unite')
class Unites extends Table {
  @override
  String get tableName => 'unite';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withLength(min: 1, max: 50)();
  TextColumn get typeGrandeur => textEnum<TypeGrandeur>()();

  /// Facteur de conversion vers l'unité de base de son `typeGrandeur`.
  RealColumn get facteurVersBase => real()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {nom},
  ];
}

/// Catalogue générique de produits, réutilisé dans le temps et distinct des
/// instances physiques ([ProduitsFrigo]). `nom` unique ; `typeGrandeur` figé à
/// la création. Voir documentation-technique.md §2 "Produit".
@DataClassName('Produit')
@TableIndex(name: 'ux_produit_code_barre', columns: {#codeBarre}, unique: true)
class Produits extends Table {
  @override
  String get tableName => 'produit';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withLength(min: 1, max: 150)();
  IntColumn get categorieId => integer().references(Categories, #id)();

  /// Fixe pour un produit donné, non modifiable après création
  /// (cf. documentation-technique.md §2 "Produit").
  TextColumn get typeGrandeur => textEnum<TypeGrandeur>()();
  IntColumn get uniteDefautId => integer().references(Unites, #id)();
  TextColumn get statut => textEnum<StatutProduit>().withDefault(
    Constant(StatutProduit.actif.name),
  )();
  DateTimeColumn get dateDerniereUtilisation => dateTime().nullable()();

  /// Code-barres EAN‑13/EAN‑8/UPC‑A/ITF‑14 renseigné via le scan (évolution
  /// v1.1, cf. Docs/poc-scan-code-barres.md). Sert de cache de reconnaissance :
  /// un code déjà connu retrouve le produit sans réseau. Nullable — tous les
  /// produits n'ont pas de code (vrac, fait maison) ; l'index UNIQUE ignore les
  /// NULL (comportement SQLite standard), donc plusieurs produits « sans code »
  /// coexistent. Ajouté par la migration de schéma v1 → v2.
  TextColumn get codeBarre => text().withLength(min: 8, max: 14).nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {nom},
  ];
}

/// Instance physique d'un [Produits] stockée dans une [Zones] : quantité, unité,
/// dates d'ajout et de péremption, statut. C'est ce que le décompte de repas
/// consomme (FIFO par péremption). Voir documentation-technique.md §2.
@DataClassName('ProduitFrigo')
class ProduitsFrigo extends Table {
  @override
  String get tableName => 'produit_frigo';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get produitId => integer().references(Produits, #id)();
  IntColumn get zoneId => integer().references(Zones, #id)();
  RealColumn get quantite => real()();
  IntColumn get uniteId => integer().references(Unites, #id)();
  DateTimeColumn get dateAjout => dateTime()();
  DateTimeColumn get datePeremption => dateTime().nullable()();
  TextColumn get statut => textEnum<StatutProduitFrigo>().withDefault(
    Constant(StatutProduitFrigo.enStock.name),
  )();

  /// Date du changement de statut (consommé/jeté), utilisée pour les
  /// statistiques anti-gaspi (hors MVP v1, cf. documentation-technique.md §5).
  DateTimeColumn get dateStatut => dateTime().nullable()();
}

/// Recette réutilisable : nom, temps de préparation, notes, portions par
/// défaut. Ses ingrédients sont dans [PlatIngredients]. Voir
/// documentation-technique.md §2 "Plat".
@DataClassName('Plat')
class Plats extends Table {
  @override
  String get tableName => 'plat';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withLength(min: 1, max: 150)();
  IntColumn get tempsPrepa => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get portionsDefaut => integer().withDefault(const Constant(1))();
}

/// Table de liaison [Plats] ↔ [Produits] : quantité d'un produit pour le nombre
/// de portions par défaut du plat. Remplacée en bloc à chaque édition du plat.
@DataClassName('PlatIngredient')
class PlatIngredients extends Table {
  @override
  String get tableName => 'plat_ingredient';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get platId => integer().references(Plats, #id)();
  IntColumn get produitId => integer().references(Produits, #id)();
  RealColumn get quantite => real()();
  IntColumn get uniteId => integer().references(Unites, #id)();
}

/// Repas planifié à une date : référence **soit** un [Plats] (`platId`), **soit**
/// un produit isolé (`produitId`) — jamais les deux, jamais aucun (invariant
/// porté par le code). Voir documentation-technique.md §2 "RepasPlanifie".
@DataClassName('RepasPlanifie')
class RepasPlanifies extends Table {
  @override
  String get tableName => 'repas_planifie';

  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get platId => integer().nullable().references(Plats, #id)();

  /// Alternative à `platId` si le repas planifié est un produit isolé, sans
  /// plat associé (cf. documentation-technique.md §2 "RepasPlanifie").
  IntColumn get produitId => integer().nullable().references(Produits, #id)();
  IntColumn get portions => integer()();
  TextColumn get statut => textEnum<StatutRepas>().withDefault(
    Constant(StatutRepas.planifie.name),
  )();
}

/// Réglages applicatifs simples, stockés en clé/valeur texte (évolution v1.1).
/// Volontairement générique : un seul enregistrement aujourd'hui, le
/// consentement à la recherche en ligne Open Food Facts
/// (`kReglageRechercheEnLigne`, cf. Docs/poc-scan-code-barres.md §5.7). Pas de
/// `SharedPreferences` : tout l'état local reste dans l'unique base SQLite.
@DataClassName('Reglage')
class Reglages extends Table {
  @override
  String get tableName => 'reglage';

  TextColumn get cle => text().withLength(min: 1, max: 100)();
  TextColumn get valeur => text()();

  @override
  Set<Column> get primaryKey => {cle};
}

/// Ligne de la liste de courses. MVP v1 : `origine` toujours `manuel`. Peut
/// être renvoyée vers le frigo (crée un [ProduitsFrigo]) une fois `achete`.
/// Voir documentation-technique.md §2 "ArticleCourse".
@DataClassName('ArticleCourse')
class ArticlesCourse extends Table {
  @override
  String get tableName => 'article_course';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get produitId => integer().references(Produits, #id)();
  RealColumn get quantite => real()();
  IntColumn get uniteId => integer().references(Unites, #id)();
  TextColumn get origine => textEnum<OrigineArticle>().withDefault(
    Constant(OrigineArticle.manuel.name),
  )();
  TextColumn get statut => textEnum<StatutArticle>().withDefault(
    Constant(StatutArticle.aAcheter.name),
  )();
}
