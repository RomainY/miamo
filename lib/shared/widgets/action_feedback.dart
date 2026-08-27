import 'package:flutter/material.dart';

import '../utils/exceptions.dart';

/// Exécute une action de repository déclenchée depuis l'UI (menu contextuel,
/// case à cocher, bouton d'icône…) : **attend** sa fin et, en cas d'échec,
/// affiche un `SnackBar` au lieu d'avaler l'erreur silencieusement.
///
/// Remplace le motif « fire-and-forget » `onPressed: () => repo.faireQqch()`
/// relevé par l'audit (BP-06), où une exception (base verrouillée, contrainte
/// violée, statut invalide…) laissait l'utilisateur sans aucun retour.
Future<void> lancerAction(
  BuildContext context,
  Future<void> Function() action, {
  String messageErreur = 'Action impossible pour le moment.',
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } on DomaineException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } on Exception catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(messageErreur)));
  }
}
