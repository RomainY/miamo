import 'package:flutter/material.dart';

import '../../../../data/repositories/produit_frigo_repository.dart';
import 'urgence_indicator.dart';

/// Formate une quantité sans décimale inutile (ex. 2.0 -> "2", 1.5 -> "1.5").
String formatQuantite(double quantite) {
  if (quantite == quantite.roundToDouble()) {
    return quantite.toStringAsFixed(0);
  }
  return quantite.toStringAsFixed(2);
}

class ProductListTile extends StatelessWidget {
  final InstanceFrigoDetail detail;
  final VoidCallback onModifier;
  final VoidCallback onConsomme;
  final VoidCallback onJete;
  final VoidCallback onSupprimer;

  /// `null` pour un produit dont le type de grandeur n'est pas "Nombre" —
  /// retirer "1" d'une masse/volume stockée n'a pas de sens (ex. -1 g sur un
  /// paquet de farine). Quand fourni, un tap = -1 immédiat, sans passer par
  /// "Modifier" (demande du 11/09/2026 : rapide à répéter, ex. yaourts x6).
  final VoidCallback? onRetirerUn;

  const ProductListTile({
    super.key,
    required this.detail,
    required this.onModifier,
    required this.onConsomme,
    required this.onJete,
    required this.onSupprimer,
    this.onRetirerUn,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onModifier,
      title: Text(detail.produit.nom),
      subtitle: Text(
        '${formatQuantite(detail.instance.quantite)} ${detail.unite.nom} '
        '· ${detail.zone.nom}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetirerUn != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Retirer 1',
              onPressed: onRetirerUn,
            ),
          UrgenceIndicator(datePeremption: detail.instance.datePeremption),
          PopupMenuButton<String>(
            onSelected: (action) {
              switch (action) {
                case 'modifier':
                  onModifier();
                case 'consomme':
                  onConsomme();
                case 'jete':
                  onJete();
                case 'supprimer':
                  onSupprimer();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'modifier', child: Text('Modifier')),
              PopupMenuItem(value: 'consomme', child: Text('Marquer consommé')),
              PopupMenuItem(value: 'jete', child: Text('Marquer jeté')),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'supprimer',
                child: Text('Supprimer (erreur de saisie)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
