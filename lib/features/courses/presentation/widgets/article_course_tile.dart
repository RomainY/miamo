import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/tables.dart';
import '../../../../data/repositories/article_course_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
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
            : (_) => ref
                  .read(articleCourseRepositoryProvider)
                  .marquerAchete(article.id),
      ),
      title: Text(
        detail.produit.nom,
        style: achete
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(
        '${formatQuantite(article.quantite)} ${detail.unite.nom}',
      ),
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
            onPressed: () => ref
                .read(articleCourseRepositoryProvider)
                .supprimer(article.id),
          ),
        ],
      ),
    );
  }
}
