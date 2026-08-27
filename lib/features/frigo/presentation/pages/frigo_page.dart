import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/theme/app_theme.dart';
import '../providers/frigo_providers.dart';
import '../widgets/category_chips_bar.dart';
import '../widgets/expiration_warning_banner.dart';
import '../widgets/product_list_tile.dart';
import 'ajouter_produit_sheet.dart';
import 'gerer_catalogue_page.dart';
import 'modifier_instance_sheet.dart';

/// Écran principal du module Frigo (cahier-des-charges.md §3.1) : liste des
/// instances en stock triées par urgence, filtrable par zone et catégorie.
class FrigoPage extends ConsumerWidget {
  const FrigoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(zonesProvider).valueOrNull ?? [];
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final zoneSelectionnee = ref.watch(frigoFiltreZoneProvider);
    final categorieSelectionnee = ref.watch(frigoFiltreCategorieProvider);
    final instances = ref.watch(instancesEnStockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frigo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Gérer le catalogue',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GererCataloguePage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const ExpirationWarningBanner(),
          const SizedBox(height: 8),
          ChipsFilterBar(
            labelToutes: 'Toutes les zones',
            options: [for (final z in zones) (z.id, z.nom)],
            selectedId: zoneSelectionnee,
            onSelected: (id) =>
                ref.read(frigoFiltreZoneProvider.notifier).state = id,
          ),
          const SizedBox(height: 8),
          ChipsFilterBar(
            labelToutes: 'Toutes les catégories',
            options: [for (final c in categories) (c.id, c.nom)],
            selectedId: categorieSelectionnee,
            colorFor: AppColors.categorieColor,
            onSelected: (id) =>
                ref.read(frigoFiltreCategorieProvider.notifier).state = id,
          ),
          const Divider(height: 16),
          Expanded(
            child: instances.when(
              data: (liste) {
                if (liste.isEmpty) {
                  return const Center(
                    child: Text('Aucun produit en stock pour ce filtre.'),
                  );
                }
                return ListView.separated(
                  itemCount: liste.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final detail = liste[i];
                    return ProductListTile(
                      detail: detail,
                      onModifier: () =>
                          showModifierInstanceSheet(context, detail),
                      onConsomme: () => ref
                          .read(produitFrigoRepositoryProvider)
                          .marquerConsomme(detail.instance.id),
                      onJete: () => ref
                          .read(produitFrigoRepositoryProvider)
                          .marquerJete(detail.instance.id),
                      onSupprimer: () => _confirmerSuppression(
                        context,
                        ref,
                        detail.instance.id,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAjouterProduitSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmerSuppression(
    BuildContext context,
    WidgetRef ref,
    int instanceId,
  ) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette ligne ?'),
        content: const Text(
          "Réservé à la correction d'une erreur de saisie : contrairement à "
          '"consommé"/"jeté", cette suppression ne compte pas dans les '
          'statistiques anti-gaspi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme == true) {
      await ref
          .read(produitFrigoRepositoryProvider)
          .supprimerInstance(instanceId);
    }
  }
}
