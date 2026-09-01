import 'package:flutter/material.dart';

import '../../domain/disponibilite_ingredients.dart';

// Mêmes teintes que le badge d'urgence de péremption (date_utils.dart).
const _couleurManquant = Color(0xFFC23B3B);
const _couleurInsuffisant = Color(0xFFB4711E);

String _fmt(double q) =>
    q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toStringAsFixed(2);

/// Pastille affichée sur un repas planifié quand au moins un ingrédient est
/// manquant ou insuffisant. N'affiche rien si tout est disponible. Un tap
/// ouvre le détail des ingrédients en défaut.
class DisponibiliteBadge extends StatelessWidget {
  final DisponibiliteRepas dispo;

  const DisponibiliteBadge({super.key, required this.dispo});

  @override
  Widget build(BuildContext context) {
    if (dispo.ok) return const SizedBox.shrink();

    final manquant = dispo.global == ManqueIngredient.manquant;
    final couleur = manquant ? _couleurManquant : _couleurInsuffisant;
    final label = manquant ? 'Ingrédient manquant' : 'Stock incomplet';

    return InkWell(
      onTap: () => _afficherDetail(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              manquant ? Icons.error_outline : Icons.warning_amber_rounded,
              size: 13,
              color: couleur,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: couleur,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _afficherDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _DetailManques(manques: dispo.manques),
    );
  }
}

class _DetailManques extends StatelessWidget {
  final List<LigneDisponibilite> manques;

  const _DetailManques({required this.manques});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingrédients à prévoir',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Comparé au stock du frigo, portions comprises.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final m in manques)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.produitNom,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Requis ${_fmt(m.requis)} ${m.uniteNom} · '
                            'dispo ${_fmt(m.disponible)} ${m.uniteNom}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _TagEtat(etat: m.etat),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TagEtat extends StatelessWidget {
  final ManqueIngredient etat;

  const _TagEtat({required this.etat});

  @override
  Widget build(BuildContext context) {
    final manquant = etat == ManqueIngredient.manquant;
    final couleur = manquant ? _couleurManquant : _couleurInsuffisant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        manquant ? 'manquant' : 'insuffisant',
        style: TextStyle(
          color: couleur,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
