import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../frigo/presentation/pages/ajouter_produit_sheet.dart'
    show quantiteInputFormatters;
import '../../../frigo/presentation/providers/frigo_providers.dart';

/// Ajouter un article manuellement à la liste de courses — produit du
/// catalogue + quantité (cahier-des-charges.md §7.6, MVP v1 manuel
/// uniquement).
Future<void> showAjouterArticleSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _AjouterArticleSheet(),
  );
}

class _AjouterArticleSheet extends ConsumerStatefulWidget {
  const _AjouterArticleSheet();

  @override
  ConsumerState<_AjouterArticleSheet> createState() =>
      _AjouterArticleSheetState();
}

class _AjouterArticleSheetState extends ConsumerState<_AjouterArticleSheet> {
  final _rechercheController = TextEditingController();
  final _quantiteController = TextEditingController(text: '1');
  Produit? _selectionne;
  bool _envoiEnCours = false;

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
            'Ajouter un article',
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
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: quantiteInputFormatters,
            decoration: InputDecoration(
              labelText: 'Quantité',
              suffixText: uniteNom,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _envoiEnCours ? null : _peutValider() ? _valider : null,
            child: _envoiEnCours
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Ajouter à la liste'),
          ),
        ],
      ),
    );
  }

  bool _peutValider() {
    if (_selectionne == null) return false;
    final quantite = double.tryParse(
      _quantiteController.text.replaceAll(',', '.'),
    );
    return quantite != null && quantite > 0;
  }

  Future<void> _valider() async {
    setState(() => _envoiEnCours = true);
    final quantite = double.parse(
      _quantiteController.text.replaceAll(',', '.'),
    );
    await ref
        .read(articleCourseRepositoryProvider)
        .ajouterManuel(
          produitId: _selectionne!.id,
          quantite: quantite,
          uniteId: _selectionne!.uniteDefautId,
        );
    if (mounted) Navigator.of(context).pop();
  }
}
