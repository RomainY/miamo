/// Exceptions métier partagées par les repositories.
///
/// Toutes dérivent de [DomaineException] et portent un [message] déjà formulé
/// pour être affiché tel quel à l'utilisateur (cf. cahier-des-charges.md §8.1
/// "message d'erreur explicite").
abstract class DomaineException implements Exception {
  const DomaineException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Levée quand un nom déjà présent dans le catalogue est réutilisé
/// (catégorie, zone, produit, plat — contrainte UNIQUE).
class DuplicateNameException extends DomaineException {
  const DuplicateNameException(super.message);
}

/// Levée quand un code-barres scanné est déjà rattaché à un autre produit
/// (index UNIQUE `ux_produit_code_barre`, cf. Docs/poc-scan-code-barres.md §5.3).
class DuplicateBarcodeException extends DomaineException {
  const DuplicateBarcodeException(super.message);
}

/// Levée lors d'une tentative de suppression de la zone racine ("Frigo",
/// is_root = true) ou de la catégorie par défaut ("Non classé").
class ElementProtegeException extends DomaineException {
  const ElementProtegeException(super.message);
}

/// Levée lors d'une tentative de suppression définitive d'un produit encore
/// au statut "actif" (seul un produit "archive" peut être supprimé).
class ProduitNonArchiveException extends DomaineException {
  const ProduitNonArchiveException(super.message);
}

/// Levée quand une entité référencée par id n'existe pas en base.
class EntiteIntrouvableException extends DomaineException {
  const EntiteIntrouvableException(super.message);
}

/// Levée quand une suppression est bloquée par une référence active ailleurs
/// (ex. un plat encore utilisé par des repas planifiés).
class ReferenceActiveException extends DomaineException {
  const ReferenceActiveException(super.message);
}
