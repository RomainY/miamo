import 'package:flutter/material.dart';

/// Dialogue de consentement à la recherche en ligne Open Food Facts
/// (cf. Docs/poc-scan-code-barres.md §5.7 / §9.1). Présenté au premier scan
/// d'un produit inconnu du catalogue.
///
/// Retourne `true` (autorise), `false` (refuse), ou `null` si l'utilisateur
/// ferme sans choisir — dans ce cas on ne mémorise rien et on redemandera.
Future<bool?> demanderConsentementOff(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Rechercher ce produit en ligne ?'),
      content: const Text(
        'Miamo peut interroger Open Food Facts — une base de données ouverte et '
        'gratuite — pour pré-remplir le nom, la catégorie et la quantité.\n\n'
        'Seul le code-barres est envoyé, aucune autre donnée. L\'application '
        'reste utilisable sans. Ce choix est modifiable dans la gestion du '
        'catalogue.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Non, saisie manuelle'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Autoriser'),
        ),
      ],
    ),
  );
}
