import '../../../data/database/app_database.dart';
import '../../../data/database/tables.dart';
import '../../../data/repositories/produit_frigo_repository.dart';
import '../../../data/repositories/repas_planifie_repository.dart';

/// Gravité du manque sur un ingrédient d'un repas planifié.
///
/// - [aucun] : le frigo couvre le besoin ;
/// - [insuffisant] : du stock existe mais en dessous du besoin ;
/// - [manquant] : rien de disponible (produit absent du frigo, ou uniquement
///   dans une grandeur incompatible).
enum ManqueIngredient { aucun, insuffisant, manquant }

int _severite(ManqueIngredient m) => switch (m) {
  ManqueIngredient.aucun => 0,
  ManqueIngredient.insuffisant => 1,
  ManqueIngredient.manquant => 2,
};

/// État d'un ingrédient donné pour un repas : besoin vs disponible, exprimés
/// dans l'unité du besoin (unité de l'ingrédient du plat, ou unité par défaut
/// du produit pour un repas « produit isolé »).
class LigneDisponibilite {
  final int produitId;
  final String produitNom;
  final double requis;
  final double disponible;
  final String uniteNom;
  final ManqueIngredient etat;

  const LigneDisponibilite({
    required this.produitId,
    required this.produitNom,
    required this.requis,
    required this.disponible,
    required this.uniteNom,
    required this.etat,
  });
}

/// Bilan de disponibilité d'un repas planifié : synthèse ([global]) et détail
/// des ingrédients en défaut ([manques]).
class DisponibiliteRepas {
  final ManqueIngredient global;
  final List<LigneDisponibilite> manques;

  const DisponibiliteRepas({required this.global, required this.manques});

  bool get ok => global == ManqueIngredient.aucun;
}

const double _epsilon = 1e-6;

/// Stock disponible agrégé, converti en unité de base par `type_grandeur`,
/// que l'allocation cumulée décrémente repas après repas.
class PoolStock {
  final Map<int, Map<TypeGrandeur, double>> _base = {};

  double disponible(int produitId, TypeGrandeur grandeur) =>
      _base[produitId]?[grandeur] ?? 0;

  void _ajouter(int produitId, TypeGrandeur grandeur, double quantiteBase) {
    (_base[produitId] ??= {}).update(
      grandeur,
      (v) => v + quantiteBase,
      ifAbsent: () => quantiteBase,
    );
  }

  /// Retire [quantiteBase] du pool (borné à 0).
  void retirer(int produitId, TypeGrandeur grandeur, double quantiteBase) {
    final restant = disponible(produitId, grandeur) - quantiteBase;
    (_base[produitId] ??= {})[grandeur] = restant < 0 ? 0 : restant;
  }
}

/// Construit le pool à partir des instances en stock. Chaque instance porte
/// déjà son [Unite] (via [InstanceFrigoDetail]), utilisé pour la conversion.
PoolStock construirePool(List<InstanceFrigoDetail> stock) {
  final pool = PoolStock();
  for (final d in stock) {
    pool._ajouter(
      d.instance.produitId,
      d.unite.typeGrandeur,
      d.instance.quantite * d.unite.facteurVersBase,
    );
  }
  return pool;
}

/// Un besoin élémentaire résolu contre le pool : produit, quantité et unité.
class _Besoin {
  final int produitId;
  final double quantite;
  final Unite unite;

  const _Besoin(this.produitId, this.quantite, this.unite);
}

List<_Besoin> _besoins(
  Plat? plat,
  Produit? produit,
  int portions,
  Map<int, List<PlatIngredient>> ingredientsParPlat,
  Map<int, Unite> unitesParId,
) {
  if (plat != null) {
    final ingredients = ingredientsParPlat[plat.id] ?? const [];
    final ratio =
        plat.portionsDefaut <= 0 ? 1.0 : portions / plat.portionsDefaut;
    return [
      for (final ing in ingredients)
        if (unitesParId[ing.uniteId] case final unite?)
          _Besoin(ing.produitId, ing.quantite * ratio, unite),
    ];
  }

  if (produit != null) {
    final unite = unitesParId[produit.uniteDefautId];
    if (unite == null) return const [];
    return [_Besoin(produit.id, portions.toDouble(), unite)];
  }

  return const [];
}

DisponibiliteRepas? _evaluerBesoins({
  required PoolStock pool,
  required List<_Besoin> besoins,
  required Map<int, Produit> produitsParId,
  required bool consommer,
}) {
  if (besoins.isEmpty) return null;

  final lignes = <LigneDisponibilite>[];
  for (final besoin in besoins) {
    final grandeur = besoin.unite.typeGrandeur;
    final besoinBase = besoin.quantite * besoin.unite.facteurVersBase;
    final dispoBase = pool.disponible(besoin.produitId, grandeur);
    final consomme = dispoBase < besoinBase ? dispoBase : besoinBase;

    final ManqueIngredient etat;
    if (besoinBase - consomme <= _epsilon) {
      etat = ManqueIngredient.aucun;
    } else if (consomme <= _epsilon) {
      etat = ManqueIngredient.manquant;
    } else {
      etat = ManqueIngredient.insuffisant;
    }

    if (consommer && consomme > 0) {
      pool.retirer(besoin.produitId, grandeur, consomme);
    }

    lignes.add(
      LigneDisponibilite(
        produitId: besoin.produitId,
        produitNom: produitsParId[besoin.produitId]?.nom ?? 'Produit inconnu',
        requis: besoin.quantite,
        disponible: dispoBase / besoin.unite.facteurVersBase,
        uniteNom: besoin.unite.nom,
        etat: etat,
      ),
    );
  }

  final global = lignes
      .map((l) => l.etat)
      .reduce((a, b) => _severite(a) >= _severite(b) ? a : b);

  return DisponibiliteRepas(
    global: global,
    manques: [
      for (final l in lignes)
        if (l.etat != ManqueIngredient.aucun) l,
    ],
  );
}

/// Évalue un repas contre le [pool]. Si [consommer], décrémente le pool des
/// quantités réellement couvertes (allocation cumulée). Renvoie `null` quand
/// le repas n'a aucun besoin à vérifier (plat sans ingrédient, données
/// incohérentes).
DisponibiliteRepas? evaluerRepas({
  required PoolStock pool,
  required RepasPlanifieDetail repas,
  required Map<int, List<PlatIngredient>> ingredientsParPlat,
  required Map<int, Unite> unitesParId,
  required Map<int, Produit> produitsParId,
  bool consommer = true,
}) {
  return _evaluerBesoins(
    pool: pool,
    besoins: _besoins(
      repas.plat,
      repas.produit,
      repas.repas.portions,
      ingredientsParPlat,
      unitesParId,
    ),
    produitsParId: produitsParId,
    consommer: consommer,
  );
}

/// Évalue un repas *candidat* (pas encore enregistré) contre le [pool] —
/// typiquement après avoir consommé les repas planifiés existants, pour un
/// aperçu en direct dans le formulaire de planification. Ne consomme pas le
/// pool par défaut.
DisponibiliteRepas? evaluerCandidat({
  required PoolStock pool,
  Plat? plat,
  Produit? produit,
  required int portions,
  required Map<int, List<PlatIngredient>> ingredientsParPlat,
  required Map<int, Unite> unitesParId,
  required Map<int, Produit> produitsParId,
  bool consommer = false,
}) {
  return _evaluerBesoins(
    pool: pool,
    besoins: _besoins(
      plat,
      produit,
      portions,
      ingredientsParPlat,
      unitesParId,
    ),
    produitsParId: produitsParId,
    consommer: consommer,
  );
}

/// Ordre d'allocation du stock : date croissante puis id croissant.
List<RepasPlanifieDetail> ordonnerPourAllocation(
  List<RepasPlanifieDetail> repas,
) {
  return [...repas]..sort((a, b) {
    final parDate = a.repas.date.compareTo(b.repas.date);
    return parDate != 0 ? parDate : a.repas.id.compareTo(b.repas.id);
  });
}

/// Allocation cumulée : parcourt les repas planifiés par date croissante (puis
/// id), en réservant le stock au fur et à mesure. Un repas peut donc manquer
/// parce qu'un repas antérieur a déjà consommé le pool.
Map<int, DisponibiliteRepas> calculerDisponibilites({
  required List<RepasPlanifieDetail> repasPlanifies,
  required List<InstanceFrigoDetail> stock,
  required Map<int, List<PlatIngredient>> ingredientsParPlat,
  required Map<int, Unite> unitesParId,
  required Map<int, Produit> produitsParId,
}) {
  final pool = construirePool(stock);

  final resultats = <int, DisponibiliteRepas>{};
  for (final repas in ordonnerPourAllocation(repasPlanifies)) {
    final dispo = evaluerRepas(
      pool: pool,
      repas: repas,
      ingredientsParPlat: ingredientsParPlat,
      unitesParId: unitesParId,
      produitsParId: produitsParId,
    );
    if (dispo != null) resultats[repas.repas.id] = dispo;
  }
  return resultats;
}
