import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/exceptions.dart';
import '../../../../shared/utils/quantite.dart';
import '../../../../shared/widgets/nouveau_produit_fields.dart';
import '../../../frigo/presentation/pages/ajouter_produit_sheet.dart'
    show quantiteInputFormatters;
import '../../../frigo/presentation/providers/frigo_providers.dart';

/// Ajouter un article à la liste de courses (cahier-des-charges.md §7.6, MVP
/// v1 manuel uniquement) — soit un produit déjà au catalogue, soit un nouveau
/// produit créé à la volée.
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
  bool _nouveauProduit = false;
  Produit? _selectionne;
  NouveauProduitBrouillon? _brouillon;
  bool _envoiEnCours = false;
  String? _erreur;

  @override
  void dispose() {
    _rechercheController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }

  /// Unité affichée en suffixe du champ quantité selon le mode courant.
  String? get _uniteNom {
    if (_nouveauProduit) return _brouillon?.uniteNom;
    if (_selectionne == null) return null;
    final unites = ref.watch(unitesProvider).valueOrNull ?? const [];
    return unites
        .firstWhereOrNull((u) => u.id == _selectionne!.uniteDefautId)
        ?.nom;
  }

  /// Le champ quantité n'a de sens qu'une fois le produit connu (existant
  /// sélectionné ou nouveau produit valide).
  bool get _produitPret =>
      _nouveauProduit ? _brouillon != null : _selectionne != null;

  @override
  Widget build(BuildContext context) {
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
              'Ajouter un article',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Produit existant')),
                ButtonSegment(value: true, label: Text('Nouveau produit')),
              ],
              selected: {_nouveauProduit},
              onSelectionChanged: (s) => setState(() {
                _nouveauProduit = s.first;
                _selectionne = null;
                _brouillon = null;
                _erreur = null;
              }),
            ),
            const SizedBox(height: 16),
            if (_nouveauProduit)
              NouveauProduitFields(
                onChanged: (b) => setState(() => _brouillon = b),
              )
            else
              _buildRecherche(),
            if (_produitPret) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _quantiteController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: quantiteInputFormatters,
                decoration: InputDecoration(
                  labelText: 'Quantité',
                  suffixText: _uniteNom,
                ),
              ),
            ],
            if (_erreur != null) ...[
              const SizedBox(height: 12),
              Text(
                _erreur!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _envoiEnCours
                  ? null
                  : _peutValider()
                  ? _valider
                  : null,
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
      ),
    );
  }

  Widget _buildRecherche() {
    final produits = ref.watch(produitsActifsProvider(null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
      ],
    );
  }

  bool _peutValider() {
    if (parseQuantite(_quantiteController.text) == null) return false;
    return _produitPret;
  }

  Future<void> _valider() async {
    final quantite = parseQuantite(_quantiteController.text);
    if (quantite == null) return;

    setState(() {
      _envoiEnCours = true;
      _erreur = null;
    });

    try {
      final int produitId;
      final int uniteId;
      if (_nouveauProduit) {
        final produit = await ref
            .read(produitRepositoryProvider)
            .create(
              nom: _brouillon!.nom,
              categorieId: _brouillon!.categorieId,
              typeGrandeur: _brouillon!.typeGrandeur,
              uniteDefautId: _brouillon!.uniteDefautId,
            );
        produitId = produit.id;
        uniteId = produit.uniteDefautId;
      } else {
        produitId = _selectionne!.id;
        uniteId = _selectionne!.uniteDefautId;
      }

      await ref
          .read(articleCourseRepositoryProvider)
          .ajouterManuel(
            produitId: produitId,
            quantite: quantite,
            uniteId: uniteId,
          );
      if (mounted) Navigator.of(context).pop();
    } on DuplicateNameException catch (e) {
      if (mounted) setState(() => _erreur = e.message);
    } catch (e) {
      if (mounted) setState(() => _erreur = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }
}
