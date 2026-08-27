/// Convertit la saisie utilisateur d'une quantité (« 1,5 », « 250 », « 0.75 »)
/// en `double` **strictement positif et fini**, ou `null` si la saisie est
/// invalide (vide, non numérique, ≤ 0, infinie/NaN).
///
/// Centralise la règle jusqu'ici réécrite — de façon incomplète — dans chaque
/// bottom sheet (cf. audit SEC-03). Accepte la virgule comme séparateur
/// décimal.
double? parseQuantite(String saisie) {
  final valeur = double.tryParse(saisie.trim().replaceAll(',', '.'));
  if (valeur == null || !valeur.isFinite || valeur <= 0) return null;
  return valeur;
}
