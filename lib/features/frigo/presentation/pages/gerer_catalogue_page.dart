import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/database/tables.dart';
import '../../../../data/repositories/produit_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/exceptions.dart';
import '../../../../shared/widgets/nom_dialog.dart';
import '../providers/frigo_providers.dart';
import '../widgets/category_chips_bar.dart';
import 'produit_form_sheet.dart';

/// Gestion CRUD du catalogue — catégories, zones et produits
/// (cahier-des-charges.md §7.1 / §7.2 / §7.3). Simplifiée à la Phase 2 : pas
/// de sélection d'icône dédiée pour catégories/zones, seul le nom est
/// éditable (icônes par défaut conservées).
class GererCataloguePage extends StatelessWidget {
  const GererCataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catalogue'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Produits'),
              Tab(text: 'Catégories'),
              Tab(text: 'Zones'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ProduitsTab(), _CategoriesTab(), _ZonesTab()],
        ),
      ),
    );
  }
}

class _ProduitsTab extends ConsumerStatefulWidget {
  const _ProduitsTab();

  @override
  ConsumerState<_ProduitsTab> createState() => _ProduitsTabState();
}

class _ProduitsTabState extends ConsumerState<_ProduitsTab> {
  int? _categorieFiltre;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final produits = ref.watch(produitsTousProvider(_categorieFiltre));
    final repo = ref.read(produitRepositoryProvider);
    final categorieNom = {for (final c in categories) c.id: c.nom};

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 8),
          ChipsFilterBar(
            labelToutes: 'Toutes les catégories',
            options: [for (final c in categories) (c.id, c.nom)],
            selectedId: _categorieFiltre,
            colorFor: AppColors.categorieColor,
            onSelected: (id) => setState(() => _categorieFiltre = id),
          ),
          const Divider(height: 16),
          Expanded(
            child: produits.when(
              data: (liste) {
                if (liste.isEmpty) {
                  return const Center(child: Text('Aucun produit.'));
                }
                return ListView.separated(
                  itemCount: liste.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final produit = liste[i];
                    final archive = produit.statut == StatutProduit.archive;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.categorieColor(
                          produit.categorieId,
                        ).withValues(alpha: archive ? 0.3 : 1),
                        radius: 6,
                      ),
                      title: Text(
                        produit.nom,
                        style: archive
                            ? TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
                            : null,
                      ),
                      subtitle: Text(
                        [
                          categorieNom[produit.categorieId] ?? '—',
                          if (archive) 'Archivé',
                        ].join(' · '),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Modifier',
                            onPressed: () =>
                                showProduitFormSheet(context, produit: produit),
                          ),
                          IconButton(
                            icon: Icon(
                              archive
                                  ? Icons.unarchive_outlined
                                  : Icons.archive_outlined,
                            ),
                            tooltip: archive ? 'Désarchiver' : 'Archiver',
                            onPressed: () => archive
                                ? repo.desarchiver(produit.id)
                                : repo.archiver(produit.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Supprimer définitivement',
                            onPressed: archive
                                ? () => _supprimerProduit(context, repo, produit)
                                : null,
                          ),
                        ],
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
        onPressed: () => showProduitFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _supprimerProduit(
    BuildContext context,
    ProduitRepository repo,
    Produit produit,
  ) async {
    final cascade = await repo.previewSuppressionCascade(produit.id);

    if (!context.mounted) return;
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer « ${produit.nom} » ?'),
        content: Text(
          cascade.estVide
              ? 'Ce produit n\'est utilisé nulle part ailleurs, la '
                    'suppression est définitive.'
              : 'Suppression définitive et en cascade de :\n'
                    '${_ligneCascade('instance(s) en frigo', cascade.instancesFrigo)}'
                    '${_ligneCascade('ingrédient(s) de plat', cascade.ingredientsPlat)}'
                    '${_ligneCascade('article(s) de courses', cascade.articlesCourse)}'
                    '${_ligneCascade('repas planifié(s)', cascade.repasPlanifies)}',
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
    if (confirme != true) return;

    try {
      await repo.supprimerDefinitivement(produit.id);
    } on ProduitNonArchiveException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  String _ligneCascade(String label, int compte) =>
      compte == 0 ? '' : '• $compte $label\n';
}

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final repo = ref.read(categorieRepositoryProvider);

    return Scaffold(
      body: categories.when(
        data: (liste) => ListView(
          children: [
            for (final categorie in liste)
              ListTile(
                title: Text(categorie.nom),
                subtitle: categorie.estParDefaut
                    ? const Text('Catégorie par défaut, non supprimable')
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showNomDialog(
                        context,
                        titre: 'Renommer',
                        valeurInitiale: categorie.nom,
                        onValider: (nom) => repo.update(categorie.id, nom: nom),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: categorie.estParDefaut
                          ? null
                          : () => _supprimer(
                              context,
                              onValider: () => repo.delete(categorie.id),
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNomDialog(
          context,
          titre: 'Nouvelle catégorie',
          onValider: (nom) => repo.create(nom: nom),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ZonesTab extends ConsumerWidget {
  const _ZonesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(zonesProvider);
    final repo = ref.read(zoneRepositoryProvider);

    return Scaffold(
      body: zones.when(
        data: (liste) => ListView(
          children: [
            for (final zone in liste)
              ListTile(
                title: Text(zone.nom),
                subtitle: zone.isRoot
                    ? const Text('Zone racine, non supprimable')
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showNomDialog(
                        context,
                        titre: 'Renommer',
                        valeurInitiale: zone.nom,
                        onValider: (nom) => repo.update(zone.id, nom: nom),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: zone.isRoot
                          ? null
                          : () => _supprimer(
                              context,
                              onValider: () => repo.delete(zone.id),
                            ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNomDialog(
          context,
          titre: 'Nouvelle zone',
          onValider: (nom) => repo.create(nom: nom),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> _supprimer(
  BuildContext context, {
  required Future<void> Function() onValider,
}) async {
  final confirme = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer ?'),
      content: const Text(
        'Les éléments liés seront automatiquement réaffectés à la valeur '
        'par défaut.',
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
  if (confirme != true) return;

  try {
    await onValider();
  } on ElementProtegeException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
