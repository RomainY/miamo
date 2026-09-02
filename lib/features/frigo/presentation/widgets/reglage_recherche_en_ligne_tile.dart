import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/reglage_repository.dart';
import '../../../../data/repositories/repository_providers.dart';

final _consentementOffProvider = StreamProvider.autoDispose<bool?>((ref) {
  return ref
      .watch(reglageRepositoryProvider)
      .observer(kReglageRechercheEnLigne)
      .map(
        (v) => switch (v) {
          'true' => true,
          'false' => false,
          _ => null,
        },
      );
});

/// Interrupteur « Recherche en ligne (Open Food Facts) » — le seul réglage de
/// l'app à ce jour (cf. Docs/poc-scan-code-barres.md §5.7). Présenté depuis la
/// gestion du catalogue.
class ReglageRechercheEnLigneTile extends ConsumerWidget {
  const ReglageRechercheEnLigneTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valeur = ref.watch(_consentementOffProvider).valueOrNull ?? false;
    return SwitchListTile(
      title: const Text('Recherche en ligne des produits'),
      subtitle: const Text(
        'Au scan d\'un code-barres inconnu, interroger Open Food Facts pour '
        'pré-remplir le nom, la catégorie et la quantité. Seul le code-barres '
        'est envoyé ; l\'application reste utilisable sans.',
      ),
      value: valeur,
      onChanged: (v) => ref
          .read(reglageRepositoryProvider)
          .ecrireBool(kReglageRechercheEnLigne, v),
    );
  }
}
