/// Sécurise l'`initialValue` d'un `DropdownButtonFormField<int>` alimenté par
/// un stream : ne renvoie [valeur] que si un item correspondant existe dans
/// [idsDisponibles], sinon `null`.
///
/// Entre la création (ou la suppression) d'une entrée et la ré-émission du
/// stream qui alimente `items`, la valeur retenue en state peut être
/// temporairement absente de la liste. Or le constructeur de
/// `DropdownButtonFormField` assère « exactly one item with value » et fait
/// planter le build (visible surtout en debug : arrêt du debugger sur
/// l'assertion). Le state applicatif, lui, reste inchangé : la sélection se
/// ré-affiche dès que le stream rattrape.
///
/// Centralise la garde jusqu'ici absente ou réécrite dans chaque bottom sheet.
int? valeurDropdownValide(int? valeur, Iterable<int> idsDisponibles) =>
    valeur != null && idsDisponibles.contains(valeur) ? valeur : null;
