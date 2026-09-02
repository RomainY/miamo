import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/database/tables.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/dropdown.dart';
import '../../../../shared/utils/exceptions.dart';
import '../../../../shared/widgets/nom_dialog.dart';
import '../providers/frigo_providers.dart';
import '../widgets/barcode_scan_button.dart';

/// Création ou modification d'un `Produit` du catalogue (cahier-des-charges.md
/// §7.3). En modification, `typeGrandeur` n'est pas éditable (fixé à la
/// création, cf. produit_repository.dart).
Future<void> showProduitFormSheet(BuildContext context, {Produit? produit}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ProduitFormSheet(produit: produit),
  );
}

class _ProduitFormSheet extends ConsumerStatefulWidget {
  final Produit? produit;

  const _ProduitFormSheet({this.produit});

  @override
  ConsumerState<_ProduitFormSheet> createState() => _ProduitFormSheetState();
}

class _ProduitFormSheetState extends ConsumerState<_ProduitFormSheet> {
  late final _nomController = TextEditingController(
    text: widget.produit?.nom ?? '',
  );
  late int? _categorieId = widget.produit?.categorieId;
  late int? _uniteId = widget.produit?.uniteDefautId;
  late TypeGrandeur _typeGrandeur =
      widget.produit?.typeGrandeur ?? TypeGrandeur.masse;
  late String? _codeBarre = widget.produit?.codeBarre;

  bool _envoiEnCours = false;
  String? _erreur;

  bool get _modification => widget.produit != null;

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _modification ? 'Modifier le produit' : 'Nouveau produit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nomController,
              autofocus: !_modification,
              decoration: const InputDecoration(labelText: 'Nom du produit'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Code-barres (optionnel)',
                border: OutlineInputBorder(),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _codeBarre ?? 'Aucun',
                      style: _codeBarre == null
                          ? TextStyle(color: Theme.of(context).hintColor)
                          : null,
                    ),
                  ),
                  if (_codeBarre != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Retirer le code-barres',
                      onPressed: () => setState(() => _codeBarre = null),
                    ),
                  BarcodeScanButton(
                    label: 'Scanner',
                    onCode: (code) => setState(() => _codeBarre = code),
                  ),
                ],
              ),
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
                        initialValue: valeurDropdownValide(
                          _categorieId,
                          liste.map((c) => c.id),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                        ),
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
            if (_modification) ...[
              // Fixé à la création, non modifiable (cf. produit_repository.dart).
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Type de grandeur',
                ),
                child: Text(_libelleTypeGrandeur(_typeGrandeur)),
              ),
            ] else ...[
              SegmentedButton<TypeGrandeur>(
                segments: const [
                  ButtonSegment(
                    value: TypeGrandeur.masse,
                    label: Text('Masse'),
                  ),
                  ButtonSegment(
                    value: TypeGrandeur.volume,
                    label: Text('Volume'),
                  ),
                  ButtonSegment(
                    value: TypeGrandeur.unite,
                    label: Text('Nombre'),
                  ),
                ],
                selected: {_typeGrandeur},
                onSelectionChanged: (s) => setState(() {
                  _typeGrandeur = s.first;
                  _uniteId = null;
                }),
              ),
            ],
            if (_typeGrandeur != TypeGrandeur.unite) ...[
              const SizedBox(height: 12),
              unites.when(
                data: (liste) {
                  final compatibles = liste
                      .where((u) => u.typeGrandeur == _typeGrandeur)
                      .toList();
                  _uniteId ??= compatibles.firstOrNull?.id;
                  return DropdownButtonFormField<int>(
                    initialValue: valeurDropdownValide(
                      _uniteId,
                      compatibles.map((u) => u.id),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Unité de suivi',
                    ),
                    items: [
                      for (final unite in compatibles)
                        DropdownMenuItem(
                          value: unite.id,
                          child: Text(unite.nom),
                        ),
                    ],
                    onChanged: (v) => setState(() => _uniteId = v),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur : $e'),
              ),
            ] else ...[
              // "Nombre" est directement rattaché à l'unité "pièce" seedée,
              // sans étape de sélection (cf. ajouter_produit_sheet.dart).
              Builder(
                builder: (context) {
                  _uniteId ??= unites.valueOrNull
                      ?.firstWhereOrNull(
                        (u) => u.typeGrandeur == TypeGrandeur.unite,
                      )
                      ?.id;
                  return const SizedBox.shrink();
                },
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
                  : Text(_modification ? 'Enregistrer' : 'Créer le produit'),
            ),
          ],
        ),
      ),
    );
  }

  String _libelleTypeGrandeur(TypeGrandeur type) => switch (type) {
    TypeGrandeur.masse => 'Masse',
    TypeGrandeur.volume => 'Volume',
    TypeGrandeur.unite => 'Nombre',
  };

  bool _peutValider() {
    return _nomController.text.trim().isNotEmpty &&
        _categorieId != null &&
        _uniteId != null;
  }

  Future<void> _valider() async {
    setState(() {
      _envoiEnCours = true;
      _erreur = null;
    });

    try {
      final repo = ref.read(produitRepositoryProvider);
      final codeBarre = _codeBarre?.trim().isEmpty ?? true ? null : _codeBarre;
      if (_modification) {
        await repo.update(
          widget.produit!.id,
          nom: _nomController.text.trim(),
          categorieId: _categorieId,
          uniteDefautId: _uniteId,
          codeBarre: Value(codeBarre),
        );
      } else {
        await repo.create(
          nom: _nomController.text.trim(),
          categorieId: _categorieId!,
          typeGrandeur: _typeGrandeur,
          uniteDefautId: _uniteId!,
          codeBarre: codeBarre,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on DuplicateNameException catch (e) {
      if (mounted) setState(() => _erreur = e.message);
    } on DuplicateBarcodeException catch (e) {
      if (mounted) setState(() => _erreur = e.message);
    } catch (e) {
      if (mounted) setState(() => _erreur = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }
}
