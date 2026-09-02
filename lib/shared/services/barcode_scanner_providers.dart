import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'barcode_scanner_service.dart';

/// Service de lecture de code-barres. Surchargé en test par un faux qui renvoie
/// un code fixe sans ouvrir la caméra.
final barcodeScannerServiceProvider = Provider<BarcodeScannerService>(
  (ref) => const MobileScannerBarcodeService(),
);
