import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/constants.dart';
import '../../../../shared/utils/date_utils.dart';
import '../providers/frigo_providers.dart';

/// Bandeau d'alerte listant les produits qui périment bientôt (≤
/// [seuilAlerteBandeauJours] jours, ou déjà périmés), indépendamment du
/// filtre actif sur l'écran Frigo. Rien ne s'affiche si aucun produit n'est
/// concerné.
class ExpirationWarningBanner extends ConsumerWidget {
  const ExpirationWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instances = ref.watch(instancesEnStockGlobalProvider).valueOrNull;
    if (instances == null) return const SizedBox.shrink();

    final proches = instances.where((d) {
      final date = d.instance.datePeremption;
      return date != null && joursRestants(date) <= seuilAlerteBandeauJours;
    }).toList();
    if (proches.isEmpty) return const SizedBox.shrink();

    const fond = Color(0xFFFBEAEA);
    const icone = Color(0xFFC23B3B);
    const titre = Color(0xFF8F2E2E);
    const corps = Color(0xFF9A4A4A);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: icone),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${proches.length} produit(s) périment bientôt',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: titre),
                ),
                Text(
                  proches.map((d) => d.produit.nom).join(', '),
                  style: const TextStyle(color: corps),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
