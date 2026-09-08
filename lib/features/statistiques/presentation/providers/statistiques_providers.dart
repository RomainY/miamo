import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/repository_providers.dart';
import '../../../planification/presentation/providers/planification_providers.dart';
import '../../domain/statistiques_anti_gaspi.dart';

/// Fenêtre affichée par l'écran anti-gaspi — fixe pour l'instant, pas de
/// réglage dédié (`Docs/poc-anti-gaspi-et-navigation.md` §A.1/§A.4).
const int moisAffichesAntiGaspi = 6;

/// Historique consommé/jeté sur les [moisAffichesAntiGaspi] derniers mois —
/// réutilise `ProduitFrigoRepository.watchHistoriqueRecent`, déjà écrit pour
/// la suggestion de rachat fréquent (v1.2).
final historiqueAntiGaspiProvider = StreamProvider((ref) {
  final depuis = DateTime.now().subtract(
    Duration(days: moisAffichesAntiGaspi * 31),
  );
  return ref.watch(produitFrigoRepositoryProvider).watchHistoriqueRecent(depuis);
});

/// Bilan anti-gaspi dérivé (agrégation pure, cf. `calculerBilanAntiGaspi`).
final bilanAntiGaspiProvider = Provider<BilanAntiGaspi>((ref) {
  final historique = ref.watch(historiqueAntiGaspiProvider).valueOrNull ?? const [];
  final produits = ref.watch(produitsParIdProvider).valueOrNull ?? const {};
  return calculerBilanAntiGaspi(historique: historique, produitsParId: produits);
});
