import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/produit_frigo_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/quantite.dart';
import '../providers/frigo_providers.dart';
import 'ajouter_produit_sheet.dart' show quantiteInputFormatters;

/// Modifier une instance : quantité, date de péremption, changement de zone
/// (cahier-des-charges.md §7.4). Le produit et l'unité (fixée à la création
/// de l'instance) ne sont pas modifiables ici.
Future<void> showModifierInstanceSheet(
  BuildContext context,
  InstanceFrigoDetail detail,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ModifierInstanceSheet(detail: detail),
  );
}

class _ModifierInstanceSheet extends ConsumerStatefulWidget {
  final InstanceFrigoDetail detail;
  const _ModifierInstanceSheet({required this.detail});

  @override
  ConsumerState<_ModifierInstanceSheet> createState() =>
      _ModifierInstanceSheetState();
}

class _ModifierInstanceSheetState
    extends ConsumerState<_ModifierInstanceSheet> {
  late int _zoneId = widget.detail.zone.id;
  late final int _uniteId = widget.detail.unite.id;
  late DateTime? _datePeremption = widget.detail.instance.datePeremption;
  late final _quantiteController = TextEditingController(
    text: formatQuantite(widget.detail.instance.quantite),
  );
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _quantiteController.dispose();
    super.dispose();
  }

  String formatQuantite(double q) =>
      q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(zonesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.detail.produit.nom,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          zones.when(
            data: (liste) => DropdownButtonFormField<int>(
              initialValue: _zoneId,
              decoration: const InputDecoration(labelText: 'Zone'),
              items: [
                for (final zone in liste)
                  DropdownMenuItem(value: zone.id, child: Text(zone.nom)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _zoneId = v);
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur : $e'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantiteController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: quantiteInputFormatters,
            decoration: InputDecoration(
              labelText: 'Quantité',
              suffixText: widget.detail.unite.nom,
            ),
          ),
          const SizedBox(height: 12),
          Row(
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
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
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
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _envoiEnCours ? null : _valider,
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

  Future<void> _valider() async {
    final quantite = parseQuantite(_quantiteController.text);
    if (quantite == null) return;

    setState(() => _envoiEnCours = true);
    await ref
        .read(produitFrigoRepositoryProvider)
        .update(
          widget.detail.instance.id,
          quantite: quantite,
          zoneId: _zoneId,
          uniteId: _uniteId,
          datePeremption: Value(_datePeremption),
        );
    if (mounted) Navigator.of(context).pop();
  }
}
