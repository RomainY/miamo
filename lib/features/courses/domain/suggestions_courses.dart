import '../../../data/database/app_database.dart';
import '../../../data/database/tables.dart';
import '../../../data/repositories/article_course_repository.dart';
import '../../../data/repositories/produit_frigo_repository.dart';
import '../../../data/repositories/repas_planifie_repository.dart';
import '../../planification/domain/disponibilite_ingredients.dart';

const double _epsilon = 1e-6;

/// Une suggestion de courses calculée à la volée, jamais persistée tant que
/// l'utilisateur ne l'a pas confirmée (`Docs/poc-liste-courses-auto.md` §2).
/// [origine] vaut toujours `suggestionPlanification` ou `suggestionRupture` —
/// jamais `manuel`.
class SuggestionArticle {
  final int produitId;
  final String produitNom;
  final double quantite;
  final int uniteId;
  final String uniteNom;
  final OrigineArticle origine;

  /// Explication courte affichable telle quelle (chip / sous-titre), sur le
  /// même principe que le "pourquoi" du chip de reconnaissance OFF.
  final String raison;

  const SuggestionArticle({
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.uniteId,
    required this.uniteNom,
    required this.origine,
    required this.raison,
  });
}

/// Suggestion "ingrédients manquants pour mes repas planifiés"
/// (`Docs/poc-liste-courses-auto.md` §3.1) : réutilise
/// [calculerManquesBaseParProduit] (même moteur, même allocation cumulée que
/// les badges de disponibilité de l'écran Planification), déduit ce qui est
/// déjà dans la liste active de courses (dédoublonnage §3.1 point 4), puis
/// convertit le solde dans l'unité par défaut du produit.
///
/// [repasParId] sert uniquement à construire la [SuggestionArticle.raison]
/// (nom du plat/produit isolé + date des repas à l'origine du manque).
List<SuggestionArticle> calculerSuggestionsPlanification({
  required List<RepasPlanifieDetail> repasPlanifies,
  required List<InstanceFrigoDetail> stock,
  required Map<int, List<PlatIngredient>> ingredientsParPlat,
  required Map<int, Unite> unitesParId,
  required Map<int, Produit> produitsParId,
  required List<ArticleCourseDetail> articlesActifs,
  required Map<int, RepasPlanifieDetail> repasParId,
}) {
  final manques = calculerManquesBaseParProduit(
    repasPlanifies: repasPlanifies,
    stock: stock,
    ingredientsParPlat: ingredientsParPlat,
    unitesParId: unitesParId,
  );
  if (manques.isEmpty) return const [];

  final dejaEnListeBase = <int, double>{};
  for (final detail in articlesActifs) {
    final base = detail.article.quantite * detail.unite.facteurVersBase;
    dejaEnListeBase.update(
      detail.article.produitId,
      (v) => v + base,
      ifAbsent: () => base,
    );
  }

  final suggestions = <SuggestionArticle>[];
  for (final entry in manques.entries) {
    final produit = produitsParId[entry.key];
    final uniteDefaut = produit == null
        ? null
        : unitesParId[produit.uniteDefautId];
    if (produit == null || uniteDefaut == null) continue;

    final solde =
        entry.value.quantiteBase - (dejaEnListeBase[entry.key] ?? 0);
    if (solde <= _epsilon) continue;

    suggestions.add(
      SuggestionArticle(
        produitId: produit.id,
        produitNom: produit.nom,
        quantite: solde / uniteDefaut.facteurVersBase,
        uniteId: uniteDefaut.id,
        uniteNom: uniteDefaut.nom,
        origine: OrigineArticle.suggestionPlanification,
        raison: _raisonPlanification(entry.value.repasIds, repasParId),
      ),
    );
  }
  return suggestions;
}

String _raisonPlanification(
  List<int> repasIds,
  Map<int, RepasPlanifieDetail> repasParId,
) {
  final labels = <String>[];
  for (final id in repasIds) {
    final repas = repasParId[id];
    if (repas == null) continue;
    final label = '${repas.titre} (${_fmtDateCourte(repas.repas.date)})';
    if (!labels.contains(label)) labels.add(label);
  }
  return labels.isEmpty ? 'Repas planifié' : 'Pour : ${labels.join(', ')}';
}

String _fmtDateCourte(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Suggestion "rachat fréquent" (`Docs/poc-liste-courses-auto.md` §3.2) :
/// produit actif, actuellement en rupture réelle (aucune instance en stock,
/// pas seulement "en dessous d'un seuil"), consommé/jeté au moins
/// [seuilFrequence] fois sur la fenêtre déjà appliquée à [historique] (filtre
/// de date fait en amont par `ProduitFrigoRepository.watchHistoriqueRecent`,
/// pas ici), et pas déjà dans la liste active de courses.
///
/// La quantité suggérée reprend celle de la dernière occurrence
/// consommée/jetée (heuristique "on rachète en général la même quantité").
List<SuggestionArticle> calculerSuggestionsRupture({
  required List<Produit> produitsActifs,
  required List<InstanceFrigoDetail> stock,
  required List<HistoriqueStatutProduit> historique,
  required Map<int, Unite> unitesParId,
  required Set<int> produitIdsDejaEnListe,
  required int seuilFrequence,
  required int periodeJours,
}) {
  final enStock = {for (final d in stock) d.instance.produitId};
  final historiqueParProduit = <int, List<HistoriqueStatutProduit>>{};
  for (final h in historique) {
    (historiqueParProduit[h.produitId] ??= []).add(h);
  }

  final suggestions = <SuggestionArticle>[];
  for (final produit in produitsActifs) {
    if (enStock.contains(produit.id)) continue;
    if (produitIdsDejaEnListe.contains(produit.id)) continue;

    final evenements = historiqueParProduit[produit.id] ?? const [];
    if (evenements.length < seuilFrequence) continue;

    final dernier = evenements.reduce(
      (a, b) => a.dateStatut.isAfter(b.dateStatut) ? a : b,
    );
    final unite = unitesParId[dernier.uniteId];
    if (unite == null) continue;

    suggestions.add(
      SuggestionArticle(
        produitId: produit.id,
        produitNom: produit.nom,
        quantite: dernier.quantite,
        uniteId: dernier.uniteId,
        uniteNom: unite.nom,
        origine: OrigineArticle.suggestionRupture,
        raison:
            'Racheté ${evenements.length} fois ces $periodeJours derniers '
            'jours',
      ),
    );
  }
  return suggestions;
}

/// Fusionne les deux origines pour un même produit : en cas de conflit, la
/// planification prime (§3.3) — une quantité de besoin précise l'emporte sur
/// une heuristique de fréquence.
List<SuggestionArticle> fusionnerSuggestions({
  required List<SuggestionArticle> planification,
  required List<SuggestionArticle> rupture,
}) {
  final produitsPlanification = {for (final s in planification) s.produitId};
  return [
    ...planification,
    ...rupture.where((s) => !produitsPlanification.contains(s.produitId)),
  ];
}
