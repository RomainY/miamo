import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/barcode_scanner_providers.dart';

/// Bouton « Scanner un code-barres » réutilisable (ajout d'instance, gestion du
/// catalogue). Appelle [onCode] avec le code lu — chiffres uniquement, longueur
/// déjà validée par le service — si l'utilisateur en scanne un.
class BarcodeScanButton extends ConsumerWidget {
  final ValueChanged<String> onCode;
  final String label;

  const BarcodeScanButton({
    super.key,
    required this.onCode,
    this.label = 'Scanner un code-barres',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.qr_code_scanner),
      label: Text(label),
      onPressed: () async {
        final code =
            await ref.read(barcodeScannerServiceProvider).scanner(context);
        if (code != null) onCode(code);
      },
    );
  }
}
