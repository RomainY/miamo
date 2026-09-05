import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/database/tables.dart';
import '../../../../data/repositories/article_course_repository.dart';
import '../../../../data/repositories/produit_frigo_repository.dart';
import '../../../../data/repositories/reglage_repository.dart';
import '../../../../data/repositories/repas_planifie_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/constants.dart' as constantes;
import '../../../frigo/presentation/providers/frigo_providers.dart';
import '../../../planification/presentation/providers/planification_providers.dart';
import '../../domain/suggestions_courses.dart';

/// Tous les articles de la liste de courses (à acheter + achetés), groupés
/// côté UI (cahier-des-charges.md §7.6).
final articlesCourseProvider = StreamProvider<List<ArticleCourseDetail>>((ref) {
  return ref.watch(articleCourseRepositoryProvider).watchAll();
});

/// Articles actifs (`a_acheter`), toute origine confondue — sert de base au
/// dédoublonnage des suggestions (`Docs/poc-liste-courses-auto.md` §3.1/§3.2).
final articlesActifsCourseProvider = StreamProvider<List<ArticleCourseDetail>>((
  ref,
) {
  return ref
      .watch(articleCourseRepositoryProvider)
      .watchAll(statut: StatutArticle.aAcheter);
});

// ─── Réglages pilotant les suggestions (v1.2, §11 du POC) ─────────────────

final suggestionPlanificationActiveProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(reglageRepositoryProvider)
      .observer(kReglageSuggestionPlanificationActive)
      .map((v) => v == null ? true : v == 'true');
});

final suggestionRuptureActiveProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(reglageRepositoryProvider)
      .observer(kReglageSuggestionRuptureActive)
      .map((v) => v == null ? true : v == 'true');
});

final seuilFrequenceRuptureProvider = StreamProvider<int>((ref) {
  return ref
      .watch(reglageRepositoryProvider)
      .observerInt(
        kReglageSeuilFrequenceRupture,
        defaut: constantes.seuilFrequenceRupture,
      );
});

final periodeRuptureJoursProvider = StreamProvider<int>((ref) {
  return ref
      .watch(reglageRepositoryProvider)
      .observerInt(
        kReglagePeriodeRuptureJours,
        defaut: constantes.periodeRuptureJours,
      );
});

/// Historique consommé/jeté sur les [periodeJours] derniers jours, brique de
/// la suggestion "rachat fréquent". `family` sur la période : un changement
/// de réglage recrée simplement le stream avec la nouvelle fenêtre.
final historiqueRuptureProvider =
    StreamProvider.family<List<HistoriqueStatutProduit>, int>((
      ref,
      periodeJours,
    ) {
      final depuis = DateTime.now().subtract(Duration(days: periodeJours));
      return ref
          .watch(produitFrigoRepositoryProvider)
          .watchHistoriqueRecent(depuis);
    });

/// Suggestions "session" ignorées par l'utilisateur (masquage temporaire,
/// non persisté — décision validée §10.3/§3.4 du POC : reset au redémarrage
/// de l'app).
final suggestionsIgnoreesProvider = StateProvider<Set<int>>((ref) => const {});

/// Suggestions de courses combinées (planification + rupture, fusionnées
/// §3.3), avant filtrage des suggestions ignorées pour la session — calculées
/// à la volée, jamais persistées tant que non confirmées (§2 du POC).
final suggestionsCourseProvider = Provider<List<SuggestionArticle>>((ref) {
  final articlesActifs =
      ref.watch(articlesActifsCourseProvider).valueOrNull ?? const [];
  final produitIdsDejaEnListe = {
    for (final a in articlesActifs) a.article.produitId,
  };

  var planification = const <SuggestionArticle>[];
  if (ref.watch(suggestionPlanificationActiveProvider).valueOrNull ?? true) {
    final repas =
        ref.watch(repasPlanifiesDetailProvider).valueOrNull ??
        const <RepasPlanifieDetail>[];
    final stock =
        ref.watch(instancesEnStockGlobalProvider).valueOrNull ?? const [];
    final ingredients =
        ref.watch(ingredientsParPlatProvider).valueOrNull ?? const {};
    final produits = ref.watch(produitsParIdProvider).valueOrNull ?? const {};
    final unites = {
      for (final u in ref.watch(unitesProvider).valueOrNull ?? const <Unite>[])
        u.id: u,
    };
    final repasParId = {for (final r in repas) r.repas.id: r};

    planification = calculerSuggestionsPlanification(
      repasPlanifies: repas,
      stock: stock,
      ingredientsParPlat: ingredients,
      unitesParId: unites,
      produitsParId: produits,
      articlesActifs: articlesActifs,
      repasParId: repasParId,
    );
  }

  var rupture = const <SuggestionArticle>[];
  if (ref.watch(suggestionRuptureActiveProvider).valueOrNull ?? true) {
    final periodeJours =
        ref.watch(periodeRuptureJoursProvider).valueOrNull ??
        constantes.periodeRuptureJours;
    final seuil =
        ref.watch(seuilFrequenceRuptureProvider).valueOrNull ??
        constantes.seuilFrequenceRupture;
    final historique =
        ref.watch(historiqueRuptureProvider(periodeJours)).valueOrNull ??
        const [];
    final produitsActifs =
        ref.watch(produitsActifsProvider(null)).valueOrNull ?? const [];
    final stock =
        ref.watch(instancesEnStockGlobalProvider).valueOrNull ?? const [];
    final unites = {
      for (final u in ref.watch(unitesProvider).valueOrNull ?? const <Unite>[])
        u.id: u,
    };

    rupture = calculerSuggestionsRupture(
      produitsActifs: produitsActifs,
      stock: stock,
      historique: historique,
      unitesParId: unites,
      produitIdsDejaEnListe: produitIdsDejaEnListe,
      seuilFrequence: seuil,
      periodeJours: periodeJours,
    );
  }

  return fusionnerSuggestions(planification: planification, rupture: rupture);
});

/// Suggestions effectivement affichées : combinées, minorées de celles
/// ignorées pour la session en cours.
final suggestionsAffichablesProvider = Provider<List<SuggestionArticle>>((
  ref,
) {
  final ignorees = ref.watch(suggestionsIgnoreesProvider);
  return ref
      .watch(suggestionsCourseProvider)
      .where((s) => !ignorees.contains(s.produitId))
      .toList();
});
