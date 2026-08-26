import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/tables.dart';
import '../providers/courses_providers.dart';
import '../widgets/article_course_tile.dart';
import 'ajouter_article_sheet.dart';

/// Écran principal du module Courses — MVP v1 manuel uniquement
/// (cahier-des-charges.md §3.3 / §7.6).
class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesCourseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: articles.when(
        data: (liste) {
          if (liste.isEmpty) {
            return const Center(child: Text('Liste de courses vide.'));
          }
          final aAcheter = liste
              .where((d) => d.article.statut == StatutArticle.aAcheter)
              .toList();
          final achetes = liste
              .where((d) => d.article.statut == StatutArticle.achete)
              .toList();

          return ListView(
            children: [
              if (aAcheter.isNotEmpty) ...[
                const _EnTeteSection('À acheter'),
                for (final detail in aAcheter)
                  ArticleCourseTile(detail: detail),
              ],
              if (achetes.isNotEmpty) ...[
                const _EnTeteSection('Achetés'),
                for (final detail in achetes)
                  ArticleCourseTile(detail: detail),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAjouterArticleSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EnTeteSection extends StatelessWidget {
  final String titre;
  const _EnTeteSection(this.titre);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        titre,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
