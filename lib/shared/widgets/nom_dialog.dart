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
  return showDialog(
    context: context,
    builder: (context) => _NomDialog(
      titre: titre,
      valeurInitiale: valeurInitiale,
      onValider: onValider,
    ),
  );
}

class _NomDialog extends StatefulWidget {
  const _NomDialog({
    required this.titre,
    required this.valeurInitiale,
    required this.onValider,
  });

  final String titre;
  final String valeurInitiale;
  final Future<void> Function(String nom) onValider;

  @override
  State<_NomDialog> createState() => _NomDialogState();
}

class _NomDialogState extends State<_NomDialog> {
  late final _controller = TextEditingController(text: widget.valeurInitiale);
  String? _erreur;
  bool _envoiEnCours = false;

  @override
  void dispose() {
    // Le controller est libéré ici (et non via `showDialog(...).whenComplete`)
    // pour couvrir toute la durée de vie du dialogue, animation de fermeture
    // comprise : un rebuild déclenché par le `onValider` de l'appelant peut
    // toucher le `TextField` alors que la route sort encore de l'écran.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    final nom = _controller.text.trim();
    if (nom.isEmpty) return;
    setState(() {
      _erreur = null;
      _envoiEnCours = true;
    });
    try {
      await widget.onValider(nom);
      if (mounted) Navigator.of(context).pop();
    } on DuplicateNameException catch (e) {
      if (mounted) {
        setState(() {
          _erreur = e.message;
          _envoiEnCours = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _envoiEnCours = false);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titre),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nom'),
            onSubmitted: (_) => _envoiEnCours ? null : _valider(),
          ),
          if (_erreur != null) ...[
            const SizedBox(height: 8),
            Text(
              _erreur!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _envoiEnCours ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _envoiEnCours ? null : _valider,
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
