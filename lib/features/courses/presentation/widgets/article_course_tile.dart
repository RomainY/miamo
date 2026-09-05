import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/tables.dart';
import '../../../../data/repositories/article_course_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/widgets/action_feedback.dart';
import '../../../frigo/presentation/widgets/product_list_tile.dart'
    show formatQuantite;
import '../pages/renvoyer_vers_frigo_sheet.dart';

/// Une ligne de la liste de courses : coche "acheté", et selon le statut,
/// action "renvoyer vers le frigo" ou suppression (cahier-des-charges.md
/// §7.6).
class ArticleCourseTile extends ConsumerWidget {
  final ArticleCourseDetail detail;
  const ArticleCourseTile({super.key, required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = detail.article;
    final achete = article.statut == StatutArticle.achete;

    return ListTile(
      leading: Checkbox(
        value: achete,
        onChanged: achete
            ? null
            : (_) => lancerAction(
                context,
                () => ref
                    .read(articleCourseRepositoryProvider)
                    .marquerAchete(article.id),
              ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              detail.produit.nom,
              overflow: TextOverflow.ellipsis,
              style: achete
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
          ),
          _OrigineIndicateur(origine: article.origine),
        ],
      ),
      subtitle: Text('${formatQuantite(article.quantite)} ${detail.unite.nom}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (achete)
            IconButton(
              icon: const Icon(Icons.kitchen_outlined),
              tooltip: 'Renvoyer vers le frigo',
              onPressed: () => showRenvoyerVersFrigoSheet(context, detail),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer',
            onPressed: () => lancerAction(
              context,
              () => ref
                  .read(articleCourseRepositoryProvider)
                  .supprimer(article.id),
            ),
          ),
        ],
      ),
    );
  }
}

/// Petit repère d'origine (rien pour un ajout manuel) — transparence sur les
/// articles issus d'une suggestion confirmée
/// (`Docs/poc-liste-courses-auto.md` §6 "micro-repère par champ").
class _OrigineIndicateur extends StatelessWidget {
  final OrigineArticle origine;
  const _OrigineIndicateur({required this.origine});

  @override
  Widget build(BuildContext context) {
    final (icone, tooltip) = switch (origine) {
      OrigineArticle.manuel => (null, null),
      OrigineArticle.suggestionPlanification => (
        Icons.restaurant_outlined,
        'Suggéré pour un repas planifié',
      ),
      OrigineArticle.suggestionRupture => (
        Icons.repeat,
        'Suggéré par rachat fréquent',
      ),
    };
    if (icone == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Tooltip(
        message: tooltip,
        child: Icon(
          icone,
          size: 15,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
