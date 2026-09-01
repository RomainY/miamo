import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/dropdown.dart';
import '../../../frigo/presentation/providers/frigo_providers.dart';
import '../../domain/disponibilite_ingredients.dart';
import '../providers/planification_providers.dart';
import 'plat_detail_screen.dart';

/// Planifier un repas — Plat ou produit isolé, sur une date donnée, avec
/// portions ajustables (cahier-des-charges.md §3.2 / §7.5).
Future<void> showPlanifierRepasSheet(
  BuildContext context, {
  required DateTime dateInitiale,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PlanifierRepasSheet(dateInitiale: dateInitiale),
  );
}

class _PlanifierRepasSheet extends ConsumerStatefulWidget {
  final DateTime dateInitiale;
  const _PlanifierRepasSheet({required this.dateInitiale});

  @override
  ConsumerState<_PlanifierRepasSheet> createState() =>
      _PlanifierRepasSheetState();
}

class _PlanifierRepasSheetState extends ConsumerState<_PlanifierRepasSheet> {
  bool _estPlat = true;
  Plat? _platSelectionne;
  Produit? _produitSelectionne;
  late DateTime _date = widget.dateInitiale;
  final _portionsController = TextEditingController(text: '1');
  bool _envoiEnCours = false;
  String? _erreur;

  @override
  void dispose() {
    _portionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plats = ref.watch(platsProvider);
    final produits = ref.watch(produitsActifsProvider(null));

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Planifier un repas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Plat')),
                ButtonSegment(value: false, label: Text('Produit isolé')),
              ],
              selected: {_estPlat},
              onSelectionChanged: (s) => setState(() {
                _estPlat = s.first;
                _platSelectionne = null;
                _produitSelectionne = null;
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Le ${_date.day.toString().padLeft(2, '0')}/'
                    '${_date.month.toString().padLeft(2, '0')}/'
                    '${_date.year}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (date != null) setState(() => _date = date);
                  },
                  child: const Text('Changer'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_estPlat)
              plats.when(
                data: (liste) {
                  if (liste.isEmpty) {
                    return FilledButton.tonalIcon(
                      onPressed: _creerNouveauPlat,
                      icon: const Icon(Icons.add),
                      label: const Text('Créer un plat'),
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: valeurDropdownValide(
                            _platSelectionne?.id,
                            liste.map((p) => p.id),
                          ),
                          decoration: const InputDecoration(labelText: 'Plat'),
                          items: [
                            for (final plat in liste)
                              DropdownMenuItem(
                                value: plat.id,
                                child: Text(plat.nom),
                              ),
                          ],
                          onChanged: (id) => setState(() {
                            _platSelectionne = liste.firstWhere(
                              (p) => p.id == id,
                            );
                            _portionsController.text = _platSelectionne!
                                .portionsDefaut
                                .toString();
                          }),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Nouveau plat',
                        onPressed: _creerNouveauPlat,
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur : $e'),
              )
            else
              produits.when(
                data: (liste) {
                  if (liste.isEmpty) {
                    return const Text('Aucun produit disponible.');
                  }
                  return DropdownButtonFormField<int>(
                    initialValue: valeurDropdownValide(
                      _produitSelectionne?.id,
                      liste.map((p) => p.id),
                    ),
                    decoration: const InputDecoration(labelText: 'Produit'),
                    items: [
                      for (final produit in liste)
                        DropdownMenuItem(
                          value: produit.id,
                          child: Text(produit.nom),
                        ),
                    ],
                    onChanged: (id) => setState(
                      () => _produitSelectionne = liste.firstWhere(
                        (p) => p.id == id,
                      ),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur : $e'),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _portionsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Portions'),
              onChanged: (_) => setState(() {}),
            ),
            _apercuDisponibilite(),
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
                  : const Text('Planifier'),
            ),
          ],
        ),
      ),
    );
  }

  /// Aperçu en direct de la disponibilité des ingrédients pour le repas en
  /// cours de saisie, calculé sur le stock résiduel une fois les repas déjà
  /// planifiés pris en compte. Purement informatif : ne bloque pas la
  /// planification.
  Widget _apercuDisponibilite() {
    final portions = int.tryParse(_portionsController.text);
    final pretPlat = _estPlat && _platSelectionne != null;
    final pretProduit = !_estPlat && _produitSelectionne != null;
    if (portions == null || portions <= 0 || (!pretPlat && !pretProduit)) {
      return const SizedBox.shrink();
    }

    final dispo = evaluerCandidat(
      pool: ref.watch(poolResiduelProvider),
      plat: pretPlat ? _platSelectionne : null,
      produit: pretProduit ? _produitSelectionne : null,
      portions: portions,
      ingredientsParPlat:
          ref.watch(ingredientsParPlatProvider).valueOrNull ?? const {},
      unitesParId: {
        for (final u in ref.watch(unitesProvider).valueOrNull ?? const <Unite>[])
          u.id: u,
      },
      produitsParId: ref.watch(produitsParIdProvider).valueOrNull ?? const {},
    );
    if (dispo == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    String fmt(double q) =>
        q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toStringAsFixed(2);

    if (dispo.ok) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF3E7C4A)),
            const SizedBox(width: 6),
            Text(
              'Tous les ingrédients sont disponibles',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final couleur = dispo.global == ManqueIngredient.manquant
        ? const Color(0xFFC23B3B)
        : const Color(0xFFB4711E);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: couleur),
              const SizedBox(width: 6),
              Text(
                dispo.global == ManqueIngredient.manquant
                    ? 'Ingrédient(s) manquant(s)'
                    : 'Stock incomplet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: couleur,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final m in dispo.manques)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• ${m.produitNom} — requis ${fmt(m.requis)} ${m.uniteNom}, '
                'dispo ${fmt(m.disponible)} ${m.uniteNom}',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  /// Crée un plat sans quitter le flux de planification (ouvre l'écran
  /// complet — ingrédients inclus — puis pré-sélectionne le plat créé).
  Future<void> _creerNouveauPlat() async {
    final plat = await Navigator.of(
      context,
    ).push<Plat>(MaterialPageRoute(builder: (_) => const PlatDetailScreen()));
    if (plat == null || !mounted) return;
    setState(() {
      _platSelectionne = plat;
      _portionsController.text = plat.portionsDefaut.toString();
    });
  }

  bool _peutValider() {
    final portions = int.tryParse(_portionsController.text);
    if (portions == null || portions <= 0) return false;
    return _estPlat ? _platSelectionne != null : _produitSelectionne != null;
  }

  Future<void> _valider() async {
    setState(() {
      _envoiEnCours = true;
      _erreur = null;
    });

    try {
      await ref
          .read(repasPlanifieRepositoryProvider)
          .planifier(
            date: _date,
            platId: _estPlat ? _platSelectionne!.id : null,
            produitId: _estPlat ? null : _produitSelectionne!.id,
            portions: int.parse(_portionsController.text),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _erreur = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }
}
