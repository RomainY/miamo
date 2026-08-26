/// Exceptions métier partagées par les repositories.
///
/// Portent un [message] déjà formulé pour être affiché tel quel à
/// l'utilisateur (cf. cahier-des-charges.md §8.1 "message d'erreur explicite").
class DuplicateNameException implements Exception {
  final String message;
  const DuplicateNameException(this.message);

  @override
  String toString() => message;
}

/// Levée lors d'une tentative de suppression de la zone racine ("Frigo",
/// is_root = true) ou de la catégorie par défaut ("Non classé").
class ElementProtegeException implements Exception {
  final String message;
  const ElementProtegeException(this.message);

  @override
  String toString() => message;
}

/// Levée lors d'une tentative de suppression définitive d'un produit encore
/// au statut "actif" (seul un produit "archive" peut être supprimé).
class ProduitNonArchiveException implements Exception {
  final String message;
  const ProduitNonArchiveException(this.message);

  @override
  String toString() => message;
}

/// Levée quand une entité référencée par id n'existe pas en base.
class EntiteIntrouvableException implements Exception {
  final String message;
  const EntiteIntrouvableException(this.message);

  @override
  String toString() => message;
}

/// Levée quand une suppression est bloquée par une référence active ailleurs
/// (ex. un plat encore utilisé par des repas planifiés).
class ReferenceActiveException implements Exception {
  final String message;
  const ReferenceActiveException(this.message);

  @override
  String toString() => message;
}
