import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/plat_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/exceptions.dart';
import 'ajouter_ingredient_sheet.dart';

class _IngredientEdit {
  final int produitId;
  final String produitNom;
  final double quantite;
  final int uniteId;
  final String uniteNom;

  const _IngredientEdit({
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.uniteId,
    required this.uniteNom,
  });
}

/// Création ou édition d'un plat : nom, temps de préparation, notes,
/// portions par défaut, et sa liste d'ingrédients (cahier-des-charges.md
/// §7.5).
class PlatDetailScreen extends ConsumerStatefulWidget {
  final Plat? plat;
  const PlatDetailScreen({super.key, this.plat});

  @override
  ConsumerState<PlatDetailScreen> createState() => _PlatDetailScreenState();
}

class _PlatDetailScreenState extends ConsumerState<PlatDetailScreen> {
  late final _nomController = TextEditingController(text: widget.plat?.nom);
  late final _tempsPrepaController = TextEditingController(
    text: widget.plat?.tempsPrepa?.toString() ?? '',
  );
  late final _notesController = TextEditingController(
    text: widget.plat?.notes ?? '',
  );
  late final _portionsController = TextEditingController(
    text: (widget.plat?.portionsDefaut ?? 1).toString(),
  );

  final _ingredients = <_IngredientEdit>[];
  bool _ingredientsCharges = false;
  bool _envoiEnCours = false;
  String? _erreur;

  bool get _modeEdition => widget.plat != null;

  @override
  void initState() {
    super.initState();
    if (_modeEdition) {
      ref.read(platRepositoryProvider).getIngredients(widget.plat!.id).then((
        liste,
      ) {
        if (!mounted) return;
        setState(() {
          _ingredients.addAll(
            liste.map(
              (d) => _IngredientEdit(
                produitId: d.produit.id,
                produitNom: d.produit.nom,
                quantite: d.ingredient.quantite,
                uniteId: d.unite.id,
                uniteNom: d.unite.nom,
              ),
            ),
          );
          _ingredientsCharges = true;
        });
      });
    } else {
      _ingredientsCharges = true;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _tempsPrepaController.dispose();
    _notesController.dispose();
    _portionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdition ? 'Modifier le plat' : 'Nouveau plat'),
        actions: [
          if (_modeEdition)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _supprimer,
            ),
        ],
      ),
      body: !_ingredientsCharges
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom du plat'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tempsPrepaController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Temps de préparation',
                          suffixText: 'min',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _portionsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Portions par défaut',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes / recette',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Ingrédients',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _ajouterIngredient,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                if (_ingredients.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Aucun ingrédient pour le moment.'),
                  ),
                for (final ingredient in _ingredients)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(ingredient.produitNom),
                    subtitle: Text(
                      '${_formatQuantite(ingredient.quantite)} ${ingredient.uniteNom}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          setState(() => _ingredients.remove(ingredient)),
                    ),
                  ),
                if (_erreur != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _erreur!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _envoiEnCours ? null : _enregistrer,
                  child: _envoiEnCours
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enregistrer'),
                ),
              ],
            ),
    );
  }

  String _formatQuantite(double q) =>
      q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toStringAsFixed(2);

  Future<void> _ajouterIngredient() async {
    final choisi = await showAjouterIngredientSheet(context);
    if (choisi == null) return;
    setState(() {
      _ingredients.removeWhere((i) => i.produitId == choisi.produit.id);
      _ingredients.add(
        _IngredientEdit(
          produitId: choisi.produit.id,
          produitNom: choisi.produit.nom,
          quantite: choisi.quantite,
          uniteId: choisi.uniteId,
          uniteNom: choisi.uniteNom,
        ),
      );
    });
  }

  Future<void> _enregistrer() async {
    final nom = _nomController.text.trim();
    final portions = int.tryParse(_portionsController.text);
    if (nom.isEmpty || portions == null || portions <= 0) {
      setState(
        () => _erreur = 'Le nom et un nombre de portions valide sont requis.',
      );
      return;
    }

    setState(() {
      _envoiEnCours = true;
      _erreur = null;
    });

    final tempsPrepa = int.tryParse(_tempsPrepaController.text);
    final notes = _notesController.text.trim();
    final ingredients = [
      for (final i in _ingredients)
        IngredientInput(
          produitId: i.produitId,
          quantite: i.quantite,
          uniteId: i.uniteId,
        ),
    ];

    try {
      final repo = ref.read(platRepositoryProvider);
      Plat plat;
      if (_modeEdition) {
        plat = await repo.update(
          widget.plat!.id,
          nom: nom,
          tempsPrepa: tempsPrepa,
          notes: notes.isEmpty ? null : notes,
          portionsDefaut: portions,
        );
        await repo.remplacerIngredients(widget.plat!.id, ingredients);
      } else {
        plat = await repo.create(
          nom: nom,
          tempsPrepa: tempsPrepa,
          notes: notes.isEmpty ? null : notes,
          portionsDefaut: portions,
          ingredients: ingredients,
        );
      }
      // Renvoie le plat créé/modifié à l'appelant (ex. planifier_repas_sheet,
      // qui le pré-sélectionne directement après création).
      if (mounted) Navigator.of(context).pop(plat);
    } on DuplicateNameException catch (e) {
      if (mounted) setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  Future<void> _supprimer() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce plat ?'),
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
      await ref.read(platRepositoryProvider).delete(widget.plat!.id);
      if (mounted) Navigator.of(context).pop();
    } on ReferenceActiveException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
