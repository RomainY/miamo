import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Longueurs des codes-barres produits usuels : EAN‑8, UPC‑A, EAN‑13, ITF‑14.
const _longueursValides = {8, 12, 13, 14};

/// Ne garde que les chiffres et ne renvoie le code que s'il a une longueur
/// plausible de code-barres produit. `null` sinon (bruit, QR code, etc.).
String? normaliserCodeBarre(String? brut) {
  if (brut == null) return null;
  final chiffres = brut.replaceAll(RegExp(r'\D'), '');
  return _longueursValides.contains(chiffres.length) ? chiffres : null;
}

/// Ouvre le lecteur de code-barres et renvoie le code lu (chiffres uniquement),
/// ou `null` si l'utilisateur annule ou refuse la caméra.
///
/// Abstrait pour être remplacé par un faux en test (aucun accès caméra).
abstract class BarcodeScannerService {
  Future<String?> scanner(BuildContext context);
}

class MobileScannerBarcodeService implements BarcodeScannerService {
  const MobileScannerBarcodeService();

  @override
  Future<String?> scanner(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const _BarcodeScannerPage(),
      ),
    );
  }
}

class _BarcodeScannerPage extends StatefulWidget {
  const _BarcodeScannerPage();

  @override
  State<_BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<_BarcodeScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    // Unités de vente au détail : EAN‑13 (le plus courant en France), EAN‑8
    // (petits emballages), UPC‑A (imports US, sous-ensemble d'EAN‑13).
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _traite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // Un controller étant fourni au widget, c'est à nous de gérer le cycle de vie
  // (cf. doc `MobileScanner.useAppLifecycleState`).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(_appliquerCycleDeVie(state));
  }

  Future<void> _appliquerCycleDeVie(AppLifecycleState state) async {
    try {
      if (state == AppLifecycleState.resumed) {
        await _controller.start();
      } else {
        await _controller.stop();
      }
    } catch (_) {
      // Controller pas encore prêt / déjà dans cet état : sans conséquence.
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_traite || capture.barcodes.isEmpty) return;
    final code = normaliserCodeBarre(capture.barcodes.first.rawValue);
    if (code == null) return;
    _traite = true;
    unawaited(HapticFeedback.mediumImpact());
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un code-barres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on),
            tooltip: 'Lampe torche',
            onPressed: () => unawaited(_controller.toggleTorch()),
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
        errorBuilder: (context, error) => _ErreurCamera(error: error),
        overlayBuilder: (context, constraints) => const _Viseur(),
      ),
    );
  }
}

class _Viseur extends StatelessWidget {
  const _Viseur();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 240,
        height: 130,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ErreurCamera extends StatelessWidget {
  final MobileScannerException error;

  const _ErreurCamera({required this.error});

  @override
  Widget build(BuildContext context) {
    final refusee =
        error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              refusee
                  ? 'Miamo n\'a pas accès à l\'appareil photo. Autorisez-le '
                        'dans les réglages du téléphone pour scanner un '
                        'code-barres.'
                  : 'Appareil photo indisponible.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Saisir à la main'),
            ),
          ],
        ),
      ),
    );
  }
}
