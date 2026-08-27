import 'package:flutter/material.dart';

import '../utils/exceptions.dart';

/// Dialogue de saisie d'un nom (création ou renommage), réutilisé pour les
/// catégories, zones, et la création rapide d'une catégorie depuis le flux
/// d'ajout produit. Si [onValider] lève une [DuplicateNameException], le
/// message est ré-affiché dans le dialogue sans le fermer.
Future<void> showNomDialog(
  BuildContext context, {
  required String titre,
  String valeurInitiale = '',
  required Future<void> Function(String nom) onValider,
}) {
  final controller = TextEditingController(text: valeurInitiale);
  String? erreur;

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(titre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            if (erreur != null) ...[
              const SizedBox(height: 8),
              Text(
                erreur!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final nom = controller.text.trim();
              if (nom.isEmpty) return;
              try {
                await onValider(nom);
                if (context.mounted) Navigator.of(context).pop();
              } on DuplicateNameException catch (e) {
                setState(() => erreur = e.message);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    ),
  ).whenComplete(controller.dispose);
}
