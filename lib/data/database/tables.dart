import 'package:drift/drift.dart';

// ─── Enums métier (cf. documentation-technique.md §2) ──────────────────────

/// Grandeur physique d'une unité / d'un produit. On ne compare ou n'additionne
/// jamais deux quantités de type_grandeur différents.
enum TypeGrandeur { masse, volume, unite }

enum StatutProduit { actif, archive }

enum StatutProduitFrigo { enStock, consomme, jete }

enum StatutRepas { planifie, fait, annule }

/// MVP v1 : seule `manuel` est utilisée. Les deux autres sont réservées à
/// l'auto-génération v1.1+ (cf. cahier-des-charges.md §3.3).
enum OrigineArticle { manuel, suggestionRupture, suggestionPlanification }

enum StatutArticle { aAcheter, achete }

// ─── Tables ──────────────────────────────────────────────────────────────
//
// Chaque table porte un @DataClassName singulier français (ex. Categories ->
// Categorie) pour coller au vocabulaire du cahier des charges, tandis que le
// nom de table SQL reste explicite via `tableName`.

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
  BoolColumn get estParDefaut =>
      boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {nom},
  ];
}

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

@DataClassName('Produit')
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
  TextColumn get statut =>
      textEnum<StatutProduit>().withDefault(
        Constant(StatutProduit.actif.name),
      )();
  DateTimeColumn get dateDerniereUtilisation => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {nom},
  ];
}

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
  TextColumn get statut =>
      textEnum<StatutProduitFrigo>().withDefault(
        Constant(StatutProduitFrigo.enStock.name),
      )();

  /// Date du changement de statut (consommé/jeté), utilisée pour les
  /// statistiques anti-gaspi (hors MVP v1, cf. documentation-technique.md §5).
  DateTimeColumn get dateStatut => dateTime().nullable()();
}

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
  TextColumn get statut =>
      textEnum<StatutRepas>().withDefault(
        Constant(StatutRepas.planifie.name),
      )();
}

@DataClassName('ArticleCourse')
class ArticlesCourse extends Table {
  @override
  String get tableName => 'article_course';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get produitId => integer().references(Produits, #id)();
  RealColumn get quantite => real()();
  IntColumn get uniteId => integer().references(Unites, #id)();
  TextColumn get origine =>
      textEnum<OrigineArticle>().withDefault(
        Constant(OrigineArticle.manuel.name),
      )();
  TextColumn get statut =>
      textEnum<StatutArticle>().withDefault(
        Constant(StatutArticle.aAcheter.name),
      )();
}
