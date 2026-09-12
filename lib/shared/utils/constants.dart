/// Seuils liés à la péremption (notifications + bandeau d'alerte).
///
/// ⚠️ Non spécifiés explicitement par le cahier des charges — valeurs de
/// départ raisonnables, à ajuster selon le retour d'usage :
/// - Notification locale envoyée [joursAvantNotification] jours avant la
///   date de péremption, à [heureNotification]h.
/// - Le bandeau d'alerte sur l'écran Frigo affiche les produits à
///   [seuilAlerteBandeauJours] jours ou moins de leur péremption (ou déjà
///   périmés).
const int joursAvantNotification = 2;
const int heureNotification = 9;
const int seuilAlerteBandeauJours = 3;

/// Seuils de la suggestion de courses "rachat fréquent"
/// (`Docs/poc-liste-courses-auto.md` §3.2). Comme ci-dessus : valeurs de
/// départ, réglables depuis l'écran Paramètres (v1.2, §11) sans recompiler —
/// ces constantes ne servent plus que de repli tant que l'utilisateur n'a
/// rien réglé.
/// - Un produit est suggéré à partir de [seuilFrequenceRupture] occurrences
///   consommé/jeté sur les [periodeRuptureJours] derniers jours.
const int seuilFrequenceRupture = 3;
const int periodeRuptureJours = 60;

/// Durée de conservation par défaut une fois un produit marqué "entamé"
/// (v1.4) — identique pour tous les produits pour le moment, pas de réglage
/// par catégorie ou par produit. Réglable depuis l'écran Paramètres ; sert de
/// valeur de repli tant que rien n'a été réglé.
const int dureeConservationApresOuvertureJours = 3;
