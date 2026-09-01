import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/tables.dart';
import '../../data/repositories/repository_providers.dart';
import '../../features/frigo/presentation/providers/frigo_providers.dart';
import '../utils/dropdown.dart';
import 'nom_dialog.dart';

/// Saisie complète et valide d'un nouveau produit du catalogue, prête à être
/// passée à `ProduitRepository.create`.
class NouveauProduitBrouillon {
  final String nom;
  final int categorieId;
  final TypeGrandeur typeGrandeur;
  final int uniteDefautId;
  final String uniteNom;

  const NouveauProduitBrouillon({
    required this.nom,
    required this.categorieId,
    required this.typeGrandeur,
    required this.uniteDefautId,
    required this.uniteNom,
  });
}

/// Champs de création d'un produit du catalogue (nom, catégorie, type de
/// grandeur, unité de suivi), réutilisables dans les différents flux qui
/// permettent de créer un produit à la volée (ajout au frigo, à la liste de
/// courses...).
///
/// Le widget gère son propre état et notifie [onChanged] à chaque
/// modification : un [NouveauProduitBrouillon] quand la saisie est complète,
/// `null` sinon.
class NouveauProduitFields extends ConsumerStatefulWidget {
  final ValueChanged<NouveauProduitBrouillon?> onChanged;

  const NouveauProduitFields({super.key, required this.onChanged});

  @override
  ConsumerState<NouveauProduitFields> createState() =>
      _NouveauProduitFieldsState();
}

class _NouveauProduitFieldsState extends ConsumerState<NouveauProduitFields> {
  final _nomController = TextEditingController();
  int? _categorieId;
  TypeGrandeur _typeGrandeur = TypeGrandeur.masse;
  int? _uniteId;

  @override
  void initState() {
    super.initState();
    Future.microtask(_chargerDefauts);
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _chargerDefauts() async {
    final categories = await ref.read(categoriesProvider.future);
    final unites = await ref.read(unitesProvider.future);
    if (!mounted) return;
    setState(() {
      _categorieId ??=
          categories.firstWhereOrNull((c) => c.estParDefaut)?.id ??
          categories.firstOrNull?.id;
      _uniteId ??= unites
          .firstWhereOrNull((u) => u.typeGrandeur == _typeGrandeur)
          ?.id;
    });
    _notifier();
  }

  void _notifier() {
    final nom = _nomController.text.trim();
    final unites = ref.read(unitesProvider).valueOrNull ?? const [];
    final unite = unites.firstWhereOrNull((u) => u.id == _uniteId);
    if (nom.isEmpty || _categorieId == null || unite == null) {
      widget.onChanged(null);
      return;
    }
    widget.onChanged(
      NouveauProduitBrouillon(
        nom: nom,
        categorieId: _categorieId!,
        typeGrandeur: _typeGrandeur,
        uniteDefautId: unite.id,
        uniteNom: unite.nom,
      ),
    );
  }

  void _changerTypeGrandeur(TypeGrandeur type) {
    final unites = ref.read(unitesProvider).valueOrNull ?? const [];
    setState(() {
      _typeGrandeur = type;
      _uniteId = unites.firstWhereOrNull((u) => u.typeGrandeur == type)?.id;
    });
    _notifier();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final unites = ref.watch(unitesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nomController,
          decoration: const InputDecoration(labelText: 'Nom du produit'),
          onChanged: (_) => _notifier(),
        ),
        const SizedBox(height: 12),
        categories.when(
          data: (liste) => Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: valeurDropdownValide(
                    _categorieId,
                    liste.map((c) => c.id),
                  ),
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: [
                    for (final categorie in liste)
                      DropdownMenuItem(
                        value: categorie.id,
                        child: Text(categorie.nom),
                      ),
                  ],
                  onChanged: (v) {
                    setState(() => _categorieId = v);
                    _notifier();
                  },
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
                    _notifier();
                  },
                ),
              ),
            ],
          ),
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
          onSelectionChanged: (s) => _changerTypeGrandeur(s.first),
        ),
        // "Nombre" (ex. "4 kiwis") est directement rattaché à l'unité "pièce"
        // seedée : pas d'étape de sélection d'unité pour un simple comptage.
        if (_typeGrandeur != TypeGrandeur.unite) ...[
          const SizedBox(height: 12),
          unites.when(
            data: (liste) {
              final compatibles = liste
                  .where((u) => u.typeGrandeur == _typeGrandeur)
                  .toList();
              return DropdownButtonFormField<int>(
                initialValue: valeurDropdownValide(
                  _uniteId,
                  compatibles.map((u) => u.id),
                ),
                decoration: const InputDecoration(labelText: 'Unité de suivi'),
                items: [
                  for (final unite in compatibles)
                    DropdownMenuItem(value: unite.id, child: Text(unite.nom)),
                ],
                onChanged: (v) {
                  setState(() => _uniteId = v);
                  _notifier();
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur : $e'),
          ),
        ],
      ],
    );
  }
}
