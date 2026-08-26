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

  const ProductListTile({
    super.key,
    required this.detail,
    required this.onModifier,
    required this.onConsomme,
    required this.onJete,
    required this.onSupprimer,
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
              PopupMenuItem(
                value: 'consomme',
                child: Text('Marquer consommé'),
              ),
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
