import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/statistiques_anti_gaspi.dart';
import '../providers/statistiques_providers.dart';

const _moisNoms = [
  'Jan',
  'Fév',
  'Mar',
  'Avr',
  'Mai',
  'Juin',
  'Juil',
  'Août',
  'Sep',
  'Oct',
  'Nov',
  'Déc',
];

const _couleurJete = Color(0xFFC23B3B);

/// Statistiques anti-gaspi — bonus par rapport au cœur de l'app (frigo,
/// planification, courses), volontairement simple : comptage de lignes,
/// fenêtre fixe, pas de nouvelle dépendance graphique
/// (`Docs/poc-anti-gaspi-et-navigation.md` Partie A).
class StatistiquesPage extends ConsumerWidget {
  const StatistiquesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bilan = ref.watch(bilanAntiGaspiProvider);
    final vide = bilan.parMois.isEmpty && bilan.topGaspillage.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques anti-gaspi')),
      body: vide
          ? const Center(
              child: Text("Pas encore d'historique sur cette période."),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ResumeCard(bilan: bilan),
                if (bilan.parMois.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Par mois', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  for (final m in bilan.parMois) _LigneMois(bilan: m),
                ],
                if (bilan.topGaspillage.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Top gaspillage',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  for (final p in bilan.topGaspillage.take(10))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.produitNom),
                      trailing: Text(
                        'jeté ${p.nbJete}x',
                        style: const TextStyle(
                          color: _couleurJete,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  final BilanAntiGaspi bilan;
  const _ResumeCard({required this.bilan});

  @override
  Widget build(BuildContext context) {
    final taux = (bilan.tauxGaspillageGlobal * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Taux de gaspillage ($moisAffichesAntiGaspi derniers mois)',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            '$taux %',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${bilan.nbConsommeTotal} consommés · ${bilan.nbJeteTotal} jetés',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Une ligne "mois" : label + mini-barre proportionnelle
/// consommé/jeté — pas de librairie de graphique, juste deux `Expanded` dans
/// un conteneur arrondi (§A.3 du POC).
class _LigneMois extends StatelessWidget {
  final BilanMensuel bilan;
  const _LigneMois({required this.bilan});

  @override
  Widget build(BuildContext context) {
    final label = '${_moisNoms[bilan.mois.month - 1]} ${bilan.mois.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: bilan.total == 0
                    ? Container(color: AppColors.chipBackground)
                    : Row(
                        children: [
                          if (bilan.nbConsomme > 0)
                            Expanded(
                              flex: bilan.nbConsomme,
                              child: Container(color: AppColors.accent),
                            ),
                          if (bilan.nbJete > 0)
                            Expanded(
                              flex: bilan.nbJete,
                              child: Container(color: _couleurJete),
                            ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 54,
            child: Text(
              '${bilan.nbConsomme}/${bilan.nbJete}',
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
