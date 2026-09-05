import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/widgets/action_feedback.dart';
import '../../domain/suggestions_courses.dart';
import '../providers/courses_providers.dart';
import 'suggestion_tile.dart';

/// Section « Suggestions » en tête de l'écran Courses (planification +
/// rupture, fusionnées) — n'affiche rien si la liste est vide
/// (`Docs/poc-liste-courses-auto.md` §6).
class SuggestionsSection extends ConsumerWidget {
  const SuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(suggestionsAffichablesProvider);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Suggestions',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _toutAjouter(context, ref, suggestions),
                child: const Text('Tout ajouter'),
              ),
            ],
          ),
        ),
        for (final s in suggestions) SuggestionTile(suggestion: s),
        const Divider(height: 16),
      ],
    );
  }

  Future<void> _toutAjouter(
    BuildContext context,
    WidgetRef ref,
    List<SuggestionArticle> suggestions,
  ) {
    final repo = ref.read(articleCourseRepositoryProvider);
    return lancerAction(context, () async {
      for (final s in suggestions) {
        await repo.ajouter(
          produitId: s.produitId,
          quantite: s.quantite,
          uniteId: s.uniteId,
          origine: s.origine,
        );
      }
    });
  }
}
