import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../frigo/presentation/pages/ajouter_produit_sheet.dart'
    show quantiteInputFormatters;
import '../../../frigo/presentation/providers/frigo_providers.dart';

class IngredientChoisi {
  final Produit produit;
  final double quantite;
  final int uniteId;
  final String uniteNom;

  const IngredientChoisi({
    required this.produit,
    required this.quantite,
    required this.uniteId,
    required this.uniteNom,
  });
}

/// Sélection d'un ingrédient (produit du catalogue + quantité) pour un plat.
/// Ne propose que des produits déjà existants ; pour un nouveau produit,
/// l'utilisateur passe par l'écran Frigo (cahier-des-charges.md §7.5, le
/// plat référence des `Produit` du catalogue).
Future<IngredientChoisi?> showAjouterIngredientSheet(BuildContext context) {
  return showModalBottomSheet<IngredientChoisi>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _AjouterIngredientSheet(),
  );
}

class _AjouterIngredientSheet extends ConsumerStatefulWidget {
  const _AjouterIngredientSheet();

  @override
  ConsumerState<_AjouterIngredientSheet> createState() =>
      _AjouterIngredientSheetState();
}

class _AjouterIngredientSheetState
    extends ConsumerState<_AjouterIngredientSheet> {
  final _rechercheController = TextEditingController();
  final _quantiteController = TextEditingController(text: '1');
  Produit? _selectionne;

  @override
  void dispose() {
    _rechercheController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produits = ref.watch(produitsActifsProvider(null));
    final unites = ref.watch(unitesProvider).valueOrNull ?? [];
    final uniteNom = _selectionne == null
        ? null
        : unites
              .where((u) => u.id == _selectionne!.uniteDefautId)
              .firstOrNull
              ?.nom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ajouter un ingrédient',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rechercheController,
            decoration: const InputDecoration(
              labelText: 'Rechercher un produit',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: produits.when(
              data: (liste) {
                final recherche = _rechercheController.text.toLowerCase();
                final filtres = recherche.isEmpty
                    ? liste
                    : liste
                          .where((p) => p.nom.toLowerCase().contains(recherche))
                          .toList();
                if (filtres.isEmpty) {
                  return const Center(child: Text('Aucun produit trouvé'));
                }
                return ListView.builder(
                  itemCount: filtres.length,
                  itemBuilder: (context, i) {
                    final produit = filtres[i];
                    final selectionne = _selectionne?.id == produit.id;
                    return ListTile(
                      title: Text(produit.nom),
                      trailing: selectionne
                          ? const Icon(Icons.check_circle)
                          : null,
                      selected: selectionne,
                      onTap: () => setState(() => _selectionne = produit),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur : $e'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantiteController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: quantiteInputFormatters,
            decoration: InputDecoration(
              labelText: 'Quantité',
              suffixText: uniteNom,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _selectionne == null || uniteNom == null
                ? null
                : () {
                    final quantite = double.tryParse(
                      _quantiteController.text.replaceAll(',', '.'),
                    );
                    if (quantite == null || quantite <= 0) return;
                    Navigator.of(context).pop(
                      IngredientChoisi(
                        produit: _selectionne!,
                        quantite: quantite,
                        uniteId: _selectionne!.uniteDefautId,
                        uniteNom: uniteNom,
                      ),
                    );
                  },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
