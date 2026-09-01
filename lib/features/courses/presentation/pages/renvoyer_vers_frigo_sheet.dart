import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/article_course_repository.dart';
import '../../../../data/repositories/repository_providers.dart';
import '../../../../shared/utils/dropdown.dart';
import '../../../frigo/presentation/providers/frigo_providers.dart';

/// Renvoie un article acheté vers le frigo, en réutilisant le flux d'ajout
/// d'une instance en zone : zone + date de péremption
/// (cahier-des-charges.md §3.3).
Future<void> showRenvoyerVersFrigoSheet(
  BuildContext context,
  ArticleCourseDetail detail,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _RenvoyerVersFrigoSheet(detail: detail),
  );
}

class _RenvoyerVersFrigoSheet extends ConsumerStatefulWidget {
  final ArticleCourseDetail detail;
  const _RenvoyerVersFrigoSheet({required this.detail});

  @override
  ConsumerState<_RenvoyerVersFrigoSheet> createState() =>
      _RenvoyerVersFrigoSheetState();
}

class _RenvoyerVersFrigoSheetState
    extends ConsumerState<_RenvoyerVersFrigoSheet> {
  int? _zoneId;
  DateTime? _datePeremption;
  bool _envoiEnCours = false;

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Renvoyer "${widget.detail.produit.nom}" vers le frigo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          zones.when(
            data: (liste) {
              _zoneId ??= liste.where((z) => z.isRoot).firstOrNull?.id;
              return DropdownButtonFormField<int>(
                initialValue: valeurDropdownValide(
                  _zoneId,
                  liste.map((z) => z.id),
                ),
                decoration: const InputDecoration(labelText: 'Zone'),
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
            onPressed: _envoiEnCours || _zoneId == null ? null : _valider,
            child: _envoiEnCours
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Renvoyer vers le frigo'),
          ),
        ],
      ),
    );
  }

  Future<void> _valider() async {
    setState(() => _envoiEnCours = true);
    await ref
        .read(articleCourseRepositoryProvider)
        .renvoyerVersFrigo(
          articleId: widget.detail.article.id,
          zoneId: _zoneId!,
          datePeremption: _datePeremption,
        );
    if (mounted) Navigator.of(context).pop();
  }
}
