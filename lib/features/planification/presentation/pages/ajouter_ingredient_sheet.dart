import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../shared/utils/dropdown.dart';
import '../../../../shared/utils/quantite.dart';
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

/// Sélection d'un ingrédient (produit du catalogue + quantité + unité) pour
/// un plat. Ne propose que des produits déjà existants ; pour un nouveau
/// produit, l'utilisateur passe par l'écran Frigo (cahier-des-charges.md
/// §7.5, le plat référence des `Produit` du catalogue).
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
  int? _uniteId;

  @override
  void dispose() {
    _rechercheController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }

  void _selectionner(Produit produit) {
    setState(() {
      _selectionne = produit;
      // Unité par défaut du produit au départ, modifiable ensuite vers toute
      // unité compatible (même `type_grandeur`).
      _uniteId = produit.uniteDefautId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final produits = ref.watch(produitsActifsProvider(null));
    final unites = ref.watch(unitesProvider).valueOrNull ?? const <Unite>[];
    final unitesCompatibles = _selectionne == null
        ? const <Unite>[]
        : unites
              .where((u) => u.typeGrandeur == _selectionne!.typeGrandeur)
              .toList();
    final uniteNom = unitesCompatibles
        .firstWhereOrNull((u) => u.id == _uniteId)
        ?.nom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
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
                            .where(
                              (p) => p.nom.toLowerCase().contains(recherche),
                            )
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
                        onTap: () => _selectionner(produit),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erreur : $e'),
              ),
            ),
            if (_selectionne != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantiteController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: quantiteInputFormatters,
                      decoration: const InputDecoration(labelText: 'Quantité'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: valeurDropdownValide(
                        _uniteId,
                        unitesCompatibles.map((u) => u.id),
                      ),
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Unité'),
                      items: [
                        for (final unite in unitesCompatibles)
                          DropdownMenuItem(
                            value: unite.id,
                            child: Text(unite.nom),
                          ),
                      ],
                      onChanged: (v) => setState(() => _uniteId = v),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _selectionne == null || uniteNom == null
                  ? null
                  : () {
                      final quantite = parseQuantite(_quantiteController.text);
                      if (quantite == null) return;
                      Navigator.of(context).pop(
                        IngredientChoisi(
                          produit: _selectionne!,
                          quantite: quantite,
                          uniteId: _uniteId!,
                          uniteNom: uniteNom,
                        ),
                      );
                    },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
