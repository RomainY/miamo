import 'package:flutter/material.dart';

import '../../../frigo/presentation/pages/gerer_catalogue_page.dart';
import '../../../parametres/presentation/widgets/reglages_sheet.dart';
import '../../../planification/presentation/pages/plats_page.dart';
import '../../../statistiques/presentation/pages/statistiques_page.dart';

/// Point d'entrée unique vers les écrans secondaires, identique sur les 3
/// onglets principaux (`Docs/poc-anti-gaspi-et-navigation.md` §B.2) : chaque
/// écran secondaire devient accessible en un tap depuis n'importe quel
/// onglet, plutôt que dispersé (Catalogue sur Frigo, Mes plats sur
/// Planification uniquement) ou enterré (Réglages, auparavant niché à
/// l'intérieur du Catalogue).
class PlusPage extends StatelessWidget {
  const PlusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plus')),
      body: ListView(
        children: [
          _EntreeMenu(
            icone: Icons.kitchen_outlined,
            titre: 'Gérer le catalogue',
            sousTitre: 'Produits, catégories, zones',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GererCataloguePage()),
            ),
          ),
          _EntreeMenu(
            icone: Icons.menu_book_outlined,
            titre: 'Mes plats',
            sousTitre: 'Recettes réutilisables pour la planification',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PlatsPage())),
          ),
          _EntreeMenu(
            icone: Icons.eco_outlined,
            titre: 'Statistiques anti-gaspi',
            sousTitre: 'Consommé vs jeté, par mois',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatistiquesPage()),
            ),
          ),
          _EntreeMenu(
            icone: Icons.tune,
            titre: 'Réglages',
            sousTitre: 'Suggestions, péremption, scan',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ReglagesPage())),
          ),
        ],
      ),
    );
  }
}

class _EntreeMenu extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  const _EntreeMenu({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone),
      title: Text(titre),
      subtitle: Text(sousTitre),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
