/// Comparaison alphabétique « naturelle » pour l'affichage de listes :
/// insensible à la casse **et** aux diacritiques, pour que « É », « é » et
/// « e » se retrouvent au même niveau (SQLite trie sur les code points bruts,
/// ce qui rejette les accentués après « z »).
int comparerAlphabetique(String a, String b) {
  final base = _clefDeTri(a).compareTo(_clefDeTri(b));
  // Départage déterministe quand les clés repliées sont égales
  // (ex. « Ete » vs « Été ») : on retombe sur la chaîne d'origine.
  return base != 0 ? base : a.compareTo(b);
}

String _clefDeTri(String valeur) {
  final buffer = StringBuffer();
  for (final rune in valeur.toLowerCase().runes) {
    buffer.write(_sansDiacritique[rune] ?? String.fromCharCode(rune));
  }
  return buffer.toString();
}

/// Repli des diacritiques latins courants (clés = code points **minuscules**,
/// `toLowerCase()` étant appliqué en amont).
const Map<int, String> _sansDiacritique = {
  0x00E0: 'a', 0x00E1: 'a', 0x00E2: 'a', 0x00E3: 'a', 0x00E4: 'a', 0x00E5: 'a',
  0x0101: 'a', 0x0103: 'a', 0x0105: 'a',
  0x00E7: 'c', 0x0107: 'c', 0x0109: 'c', 0x010B: 'c', 0x010D: 'c',
  0x00F0: 'd', 0x010F: 'd', 0x0111: 'd',
  0x00E8: 'e', 0x00E9: 'e', 0x00EA: 'e', 0x00EB: 'e', 0x0113: 'e', 0x0115: 'e',
  0x0117: 'e', 0x0119: 'e', 0x011B: 'e',
  0x011F: 'g', 0x0121: 'g', 0x0123: 'g',
  0x00EC: 'i', 0x00ED: 'i', 0x00EE: 'i', 0x00EF: 'i', 0x0129: 'i', 0x012B: 'i',
  0x012D: 'i', 0x012F: 'i', 0x0131: 'i',
  0x0137: 'k',
  0x013A: 'l', 0x013C: 'l', 0x013E: 'l', 0x0142: 'l',
  0x00F1: 'n', 0x0144: 'n', 0x0146: 'n', 0x0148: 'n',
  0x00F2: 'o', 0x00F3: 'o', 0x00F4: 'o', 0x00F5: 'o', 0x00F6: 'o', 0x00F8: 'o',
  0x014D: 'o', 0x014F: 'o', 0x0151: 'o',
  0x0155: 'r', 0x0157: 'r', 0x0159: 'r',
  0x015B: 's', 0x015D: 's', 0x015F: 's', 0x0161: 's',
  0x0163: 't', 0x0165: 't', 0x0167: 't',
  0x00F9: 'u', 0x00FA: 'u', 0x00FB: 'u', 0x00FC: 'u', 0x0169: 'u', 0x016B: 'u',
  0x016D: 'u', 0x016F: 'u', 0x0171: 'u', 0x0173: 'u',
  0x00FD: 'y', 0x00FF: 'y',
  0x017A: 'z', 0x017C: 'z', 0x017E: 'z',
  // Ligatures / cas particuliers
  0x00E6: 'ae', 0x0153: 'oe', 0x00DF: 'ss',
};
