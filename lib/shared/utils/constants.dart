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
