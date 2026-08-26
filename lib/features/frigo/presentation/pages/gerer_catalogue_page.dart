import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/exceptions.dart';
import '../../../../shared/widgets/nom_dialog.dart';
import '../providers/frigo_providers.dart';

/// Gestion CRUD des catégories et zones (cahier-des-charges.md §7.1 / §7.2).
/// Simplifiée à la Phase 2 : pas de sélection d'icône dédiée pour l'instant,
/// seul le nom est éditable (icônes par défaut conservées).
class GererCataloguePage extends StatelessWidget {
  const GererCataloguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catégories & zones'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Catégories'), Tab(text: 'Zones')],
          ),
        ),
        body: const TabBarView(
          children: [_CategoriesTab(), _ZonesTab()],
        ),
      ),
    );
  }
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
