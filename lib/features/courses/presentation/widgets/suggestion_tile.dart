import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/tables.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/widgets/action_feedback.dart';
import '../../../frigo/presentation/widgets/product_list_tile.dart'
    show formatQuantite;
import '../../domain/suggestions_courses.dart';
import '../providers/courses_providers.dart';

/// Une ligne de suggestion (planification ou rupture), affichée dans
/// [SuggestionsSection] — jamais persistée tant que l'utilisateur n'a pas
/// tapé « Ajouter » (`Docs/poc-liste-courses-auto.md` §2/§6). « Ignorer »
/// masque la suggestion pour la session en cours uniquement (§3.4).
class SuggestionTile extends ConsumerWidget {
  final SuggestionArticle suggestion;
  const SuggestionTile({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planification =
        suggestion.origine == OrigineArticle.suggestionPlanification;

    return ListTile(
      leading: Icon(
        planification ? Icons.restaurant_outlined : Icons.repeat,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(suggestion.produitNom),
      subtitle: Text(
        '${formatQuantite(suggestion.quantite)} ${suggestion.uniteNom} · '
        '${suggestion.raison}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Ajouter à la liste',
            onPressed: () => lancerAction(
              context,
              () => ref
                  .read(articleCourseRepositoryProvider)
                  .ajouter(
                    produitId: suggestion.produitId,
                    quantite: suggestion.quantite,
                    uniteId: suggestion.uniteId,
                    origine: suggestion.origine,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Ignorer pour cette session',
            onPressed: () => ref
                .read(suggestionsIgnoreesProvider.notifier)
                .update((ignorees) => {...ignorees, suggestion.produitId}),
          ),
        ],
      ),
    );
  }
}
