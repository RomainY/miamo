import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/database/tables.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/exceptions.dart';
import '../../../../shared/widgets/nom_dialog.dart';
import '../providers/frigo_providers.dart';

/// N'autorise que des chiffres et un séparateur décimal (`.` ou `,`) dans un
/// champ de quantité.
final quantiteInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

/// Ajout d'une instance en zone — deux chemins possibles
/// (documentation-technique.md §3 "Flux d'ajout d'un ProduitFrigo") :
/// A. sélection d'un produit déjà connu (autocomplétion) ;
/// B. création d'un nouveau produit à la volée, dans le même flux.
Future<void> showAjouterProduitSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _AjouterProduitSheet(),
  );
}

class _AjouterProduitSheet extends ConsumerStatefulWidget {
  const _AjouterProduitSheet();

  @override
  ConsumerState<_AjouterProduitSheet> createState() =>
      _AjouterProduitSheetState();
}

class _AjouterProduitSheetState extends ConsumerState<_AjouterProduitSheet> {
  bool _nouveauProduit = false;
  Produit? _produitSelectionne;
  final _rechercheController = TextEditingController();

  final _nomController = TextEditingController();
  int? _categorieId;
  TypeGrandeur _typeGrandeur = TypeGrandeur.masse;

  int? _zoneId;
  final _quantiteController = TextEditingController(text: '1');
  int? _uniteId;
  DateTime? _datePeremption;

  bool _envoiEnCours = false;
  String? _erreur;

  @override
  void dispose() {
    _rechercheController.dispose();
    _nomController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }

  TypeGrandeur? get _typeGrandeurActive =>
      _nouveauProduit ? _typeGrandeur : _produitSelectionne?.typeGrandeur;

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider);
    final categories = ref.watch(categoriesProvider);
    final unites = ref.watch(unitesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ajouter un produit',
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
                _produitSelectionne = null;
                _uniteId = null;
              }),
            ),
            const SizedBox(height: 16),
            if (!_nouveauProduit) ...[
              _buildRecherche(),
            ] else ...[
              _buildNouveauProduit(categories, unites),
            ],
            const SizedBox(height: 16),
            if (_typeGrandeurActive != null) ...[
              Text('Zone', style: Theme.of(context).textTheme.labelLarge),
              zones.when(
                data: (liste) {
                  _zoneId ??= liste.where((z) => z.isRoot).firstOrNull?.id;
                  return DropdownButtonFormField<int>(
                    initialValue: _zoneId,
                    items: [
                      for (final zone in liste)
                        DropdownMenuItem(value: zone.id, child: Text(zone.nom)),
                    ],
                    onChanged: (v) => setState(() => _zoneId = v),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur : $e'),
              ),
              const SizedBox(height: 12),
              unites.when(
                data: (liste) {
                  final estUnComptage =
                      _typeGrandeurActive == TypeGrandeur.unite;
                  final uniteChoisie = liste.firstWhereOrNull(
                    (u) => u.id == _uniteId,
                  );
                  return TextField(
                    controller: _quantiteController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: quantiteInputFormatters,
                    decoration: InputDecoration(
                      labelText: 'Quantité',
                      suffixText: estUnComptage ? null : uniteChoisie?.nom,
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur : $e'),
              ),
              const SizedBox(height: 12),
              _buildDatePeremption(),
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
                  : const Text('Ajouter au frigo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecherche() {
    final categorieId = ref.watch(frigoFiltreCategorieProvider);
    final produits = ref.watch(produitsActifsProvider(categorieId));

    return SizedBox(
      height: 220,
      child: Column(
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
          Expanded(
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
                    final selectionne = _produitSelectionne?.id == produit.id;
                    return ListTile(
                      title: Text(produit.nom),
                      trailing: selectionne
                          ? const Icon(Icons.check_circle)
                          : null,
                      selected: selectionne,
                      onTap: () => setState(() {
                        _produitSelectionne = produit;
                        _uniteId = produit.uniteDefautId;
                      }),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur : $e'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNouveauProduit(
    AsyncValue<List<Categorie>> categories,
    AsyncValue<List<Unite>> unites,
  ) {
    if (_typeGrandeur == TypeGrandeur.unite) {
      _uniteId ??= unites.valueOrNull
          ?.firstWhereOrNull((u) => u.typeGrandeur == TypeGrandeur.unite)
          ?.id;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nomController,
          decoration: const InputDecoration(labelText: 'Nom du produit'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        categories.when(
          data: (liste) {
            _categorieId ??=
                liste.where((c) => c.estParDefaut).firstOrNull?.id ??
                liste.firstOrNull?.id;
            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _categorieId,
                    decoration: const InputDecoration(labelText: 'Catégorie'),
                    items: [
                      for (final categorie in liste)
                        DropdownMenuItem(
                          value: categorie.id,
                          child: Text(categorie.nom),
                        ),
                    ],
                    onChanged: (v) => setState(() => _categorieId = v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Nouvelle catégorie',
                  onPressed: () => showNomDialog(
                    context,
                    titre: 'Nouvelle catégorie',
                    onValider: (nom) async {
                      final categorie = await ref
                          .read(categorieRepositoryProvider)
                          .create(nom: nom);
                      setState(() => _categorieId = categorie.id);
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Erreur : $e'),
        ),
        const SizedBox(height: 12),
        SegmentedButton<TypeGrandeur>(
          segments: const [
            ButtonSegment(value: TypeGrandeur.masse, label: Text('Masse')),
            ButtonSegment(value: TypeGrandeur.volume, label: Text('Volume')),
            ButtonSegment(value: TypeGrandeur.unite, label: Text('Nombre')),
          ],
          selected: {_typeGrandeur},
          onSelectionChanged: (s) => setState(() {
            _typeGrandeur = s.first;
            _uniteId = null;
          }),
        ),
        // "Nombre" (ex. "4 kiwis") ne propose pas de choix d'unité : le
        // produit est directement rattaché à l'unité "pièce" seedée, sans
        // étape de sélection superflue pour un simple comptage.
        if (_typeGrandeur != TypeGrandeur.unite) ...[
          const SizedBox(height: 12),
          unites.when(
            data: (liste) {
              final compatibles = liste
                  .where((u) => u.typeGrandeur == _typeGrandeur)
                  .toList();
              _uniteId ??= compatibles.firstOrNull?.id;
              return DropdownButtonFormField<int>(
                initialValue: _uniteId,
                decoration: const InputDecoration(labelText: 'Unité de suivi'),
                items: [
                  for (final unite in compatibles)
                    DropdownMenuItem(value: unite.id, child: Text(unite.nom)),
                ],
                onChanged: (v) => setState(() => _uniteId = v),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur : $e'),
          ),
        ],
      ],
    );
  }

  Widget _buildDatePeremption() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _datePeremption == null
                ? 'Pas de date de péremption'
                : 'Périme le ${_datePeremption!.day.toString().padLeft(2, '0')}/'
                      '${_datePeremption!.month.toString().padLeft(2, '0')}/'
                      '${_datePeremption!.year}',
          ),
        ),
        TextButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _datePeremption ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (date != null) setState(() => _datePeremption = date);
          },
          child: const Text('Choisir'),
        ),
        if (_datePeremption != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => setState(() => _datePeremption = null),
          ),
      ],
    );
  }

  bool _peutValider() {
    if (_zoneId == null || _uniteId == null) return false;
    if (double.tryParse(_quantiteController.text.replaceAll(',', '.')) ==
        null) {
      return false;
    }
    if (_nouveauProduit) {
      return _nomController.text.trim().isNotEmpty && _categorieId != null;
    }
    return _produitSelectionne != null;
  }

  Future<void> _valider() async {
    setState(() {
      _envoiEnCours = true;
      _erreur = null;
    });

    final quantite = double.parse(
      _quantiteController.text.replaceAll(',', '.'),
    );

    try {
      int produitId;
      if (_nouveauProduit) {
        final produit = await ref
            .read(produitRepositoryProvider)
            .create(
              nom: _nomController.text.trim(),
              categorieId: _categorieId!,
              typeGrandeur: _typeGrandeur,
              uniteDefautId: _uniteId!,
            );
        produitId = produit.id;
      } else {
        produitId = _produitSelectionne!.id;
      }

      await ref
          .read(produitFrigoRepositoryProvider)
          .create(
            produitId: produitId,
            zoneId: _zoneId!,
            quantite: quantite,
            uniteId: _uniteId!,
            datePeremption: _datePeremption,
          );

      if (mounted) Navigator.of(context).pop();
    } on DuplicateNameException catch (e) {
      setState(() => _erreur = e.message);
    } catch (e) {
      setState(() => _erreur = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }
}
