import '../../data/database/tables.dart';

/// Logique **pure** de traduction d'une fiche Open Food Facts vers les champs du
/// catalogue Miamo (cf. Docs/poc-scan-code-barres.md §5.4 & §5.8). Aucune
/// dépendance Flutter/Drift : testable isolément.
///
/// > Les tables `_bucketTags` / `_bucketAlias` sont un **premier jet** (aucun
/// > échantillon terrain formel n'a été collecté). À affiner à l'usage.

// ─────────────────────────────────────────────────────────────────────────────
// Étage 1 — categories_tags Open Food Facts → « bucket » figé
// ─────────────────────────────────────────────────────────────────────────────

/// Familles alimentaires cibles, possédées par le code (stables).
const kBuckets = <String>[
  'cremerie',
  'boissons',
  'surgeles',
  'viandes_poissons',
  'fruits_legumes',
  'feculents',
  'epicerie_sucree',
  'epicerie_salee',
  'petit_dejeuner',
  'autre',
];

/// `bucket → tags OFF (préfixe `en:`)` par correspondance **exacte**.
const _bucketTags = <String, List<String>>{
  'cremerie': [
    'en:dairies', 'en:milks', 'en:yogurts', 'en:fermented-milk-products',
    'en:cheeses', 'en:creams', 'en:butters', 'en:fresh-dairy-products',
    'en:dairy-desserts', 'en:fermented-dairy-desserts',
  ],
  'boissons': [
    'en:beverages', 'en:waters', 'en:spring-waters', 'en:mineral-waters',
    'en:sodas', 'en:sweetened-beverages', 'en:fruit-juices', 'en:juices',
    'en:nectars', 'en:hot-beverages', 'en:coffees', 'en:teas',
    'en:plant-based-beverages', 'en:alcoholic-beverages', 'en:beers', 'en:wines',
  ],
  'surgeles': [
    'en:frozen-foods', 'en:frozen-desserts', 'en:ice-creams-and-sorbets',
    'en:ice-creams', 'en:sorbets',
  ],
  'viandes_poissons': [
    'en:meats', 'en:meats-and-their-products', 'en:prepared-meats', 'en:poultry',
    'en:hams', 'en:sausages', 'en:seafood', 'en:fishes',
    'en:fishes-and-their-products', 'en:smoked-fishes', 'en:canned-fishes',
  ],
  'fruits_legumes': [
    'en:fruits', 'en:vegetables', 'en:fresh-vegetables', 'en:fresh-fruits',
    'en:legumes', 'en:legumes-and-their-products', 'en:fruits-based-foods',
    'en:vegetables-based-foods', 'en:salads',
  ],
  'feculents': [
    'en:cereals-and-potatoes', 'en:cereals-and-their-products', 'en:pastas',
    'en:fresh-pastas', 'en:rices', 'en:breads', 'en:flours', 'en:semolinas',
    'en:potatoes', 'en:pulses',
  ],
  'epicerie_sucree': [
    'en:sugary-snacks', 'en:biscuits-and-cakes', 'en:biscuits', 'en:cakes',
    'en:chocolates', 'en:chocolate-candies', 'en:confectioneries', 'en:candies',
    'en:sweet-spreads', 'en:jams', 'en:honeys', 'en:desserts',
  ],
  'epicerie_salee': [
    'en:salty-snacks', 'en:crisps', 'en:chips-and-fries', 'en:appetizers',
    'en:sauces', 'en:condiments', 'en:spices', 'en:salt', 'en:olive-oils',
    'en:vegetable-oils', 'en:vinegars', 'en:canned-foods',
    'en:canned-vegetables', 'en:soups', 'en:meals', 'en:prepared-meals',
    'en:pizzas',
  ],
  'petit_dejeuner': [
    'en:breakfasts', 'en:breakfast-cereals', 'en:cereals', 'en:mueslis',
    'en:spreads', 'en:hazelnut-spreads', 'en:cocoa-and-chocolate-powders',
    'en:viennoiseries',
  ],
};

final Map<String, String> _tagVersBucket = {
  for (final entry in _bucketTags.entries)
    for (final tag in entry.value) tag: entry.key,
};

class ResolutionBucket {
  /// L'un de [kBuckets] ; `'autre'` si aucun tag n'a matché.
  final String bucket;

  /// Le tag OFF qui a déclenché le rattachement (`null` si `bucket == 'autre'`).
  final String? tagDeclencheur;

  const ResolutionBucket(this.bucket, this.tagDeclencheur);
}

/// Parcourt les `categories_tags` du **plus spécifique au plus générique**
/// (OFF les fournit grosso modo dans l'ordre inverse), premier match gagné.
ResolutionBucket resolveBucket(List<String> categoriesTags) {
  for (final tag in categoriesTags.reversed) {
    final bucket = _tagVersBucket[tag.trim().toLowerCase()];
    if (bucket != null) return ResolutionBucket(bucket, tag);
  }
  return const ResolutionBucket('autre', null);
}

// ─────────────────────────────────────────────────────────────────────────────
// Étage 2 — bucket → Categorie de l'utilisateur
// ─────────────────────────────────────────────────────────────────────────────

/// Nom de catégorie proposé par défaut pour un bucket (création en 1 tap).
const bucketNomCategorie = <String, String>{
  'cremerie': 'Frais',
  'boissons': 'Boissons',
  'surgeles': 'Surgelés',
  'viandes_poissons': 'Viandes & poissons',
  'fruits_legumes': 'Fruits & légumes',
  'feculents': 'Féculents',
  'epicerie_sucree': 'Épicerie sucrée',
  'epicerie_salee': 'Épicerie salée',
  'petit_dejeuner': 'Petit-déjeuner',
  'autre': 'Non classé',
};

/// Noms (à normaliser) qui, s'ils existent déjà chez l'utilisateur, valent le
/// bucket → pré-sélection sans rien créer.
const _bucketAlias = <String, List<String>>{
  'cremerie': [
    'frais', 'cremerie', 'produits frais', 'frigo', 'laitages', 'yaourts',
    'fromages',
  ],
  'boissons': ['boissons', 'boisson', 'boire', 'jus', 'sodas'],
  'surgeles': ['surgeles', 'surgele', 'congelateur', 'congele', 'glaces'],
  'viandes_poissons': [
    'viandes & poissons', 'viande', 'viandes', 'poisson', 'poissons',
    'boucherie', 'charcuterie',
  ],
  'fruits_legumes': [
    'fruits & legumes', 'fruits', 'legumes', 'primeur', 'fruits et legumes',
  ],
  'feculents': [
    'feculents', 'feculent', 'pates', 'riz', 'pates riz', 'cereales',
  ],
  'epicerie_sucree': [
    'epicerie sucree', 'sucre', 'gouter', 'biscuits', 'chocolat',
  ],
  'epicerie_salee': [
    'epicerie salee', 'epicerie', 'conserves', 'sauces', 'plats prepares',
  ],
  'petit_dejeuner': [
    'petit-dejeuner', 'petit dejeuner', 'matin', 'cereales petit dejeuner',
  ],
  'autre': ['non classe', 'autre', 'divers'],
};

/// Minuscule + sans diacritiques + espaces compactés, pour comparer des noms.
String normaliserNom(String s) {
  const avec = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿœæ';
  const sans = 'aaaaaaceeeeiiiinooooouuuuyyoa';
  final out = s.toLowerCase().trim();
  final sb = StringBuffer();
  for (final ch in out.split('')) {
    final i = avec.indexOf(ch);
    sb.write(i == -1 ? ch : sans[i]);
  }
  return sb.toString().replaceAll(RegExp(r'\s+'), ' ');
}

class CorrespondanceCategorie {
  /// Nom exact d'une catégorie utilisateur existante, si trouvée.
  final String? categorieExistante;

  /// Nom par défaut du bucket, à proposer à la création si rien n'a été trouvé.
  final String nomAProposer;

  const CorrespondanceCategorie(this.categorieExistante, this.nomAProposer);
}

/// Cherche, parmi [nomsCategoriesUtilisateur], une catégorie qui colle au
/// [bucket]. Ne crée jamais rien.
CorrespondanceCategorie mapperCategorie(
  String bucket,
  Iterable<String> nomsCategoriesUtilisateur,
) {
  final nomDefaut = bucketNomCategorie[bucket] ?? 'Non classé';
  final alias = {
    normaliserNom(nomDefaut),
    ...?_bucketAlias[bucket]?.map(normaliserNom),
  };
  for (final nom in nomsCategoriesUtilisateur) {
    if (alias.contains(normaliserNom(nom))) {
      return CorrespondanceCategorie(nom, nomDefaut);
    }
  }
  return CorrespondanceCategorie(null, nomDefaut);
}

// ─────────────────────────────────────────────────────────────────────────────
// Parsing de `quantity`
// ─────────────────────────────────────────────────────────────────────────────

class QuantiteOff {
  /// Total, multipack déplié (`6 x 125 g` → 750). `null` si non reconnu.
  final double? valeur;

  /// Nom d'unité Miamo : `gramme` / `kilogramme` / `millilitre` / `litre` /
  /// `pièce`. `null` si non reconnu.
  final String? uniteNom;
  final TypeGrandeur? typeGrandeur;

  /// Ce que le parseur a compris (trace lisible).
  final String note;

  const QuantiteOff(this.valeur, this.uniteNom, this.typeGrandeur, this.note);

  static const nonReconnu = QuantiteOff(null, null, null, 'non reconnu');
}

/// `token → (unité Miamo, grandeur, facteur vers cette unité)`.
const _unites = <String, (String, TypeGrandeur, double)>{
  'mg': ('gramme', TypeGrandeur.masse, 0.001),
  'g': ('gramme', TypeGrandeur.masse, 1),
  'gr': ('gramme', TypeGrandeur.masse, 1),
  'kg': ('kilogramme', TypeGrandeur.masse, 1),
  'ml': ('millilitre', TypeGrandeur.volume, 1),
  'cl': ('millilitre', TypeGrandeur.volume, 10),
  'dl': ('millilitre', TypeGrandeur.volume, 100),
  'l': ('litre', TypeGrandeur.volume, 1),
};

QuantiteOff parseQuantiteOff(String? brut) {
  if (brut == null || brut.trim().isEmpty) return QuantiteOff.nonReconnu;
  final s = brut
      .toLowerCase()
      .replaceAll(',', '.')
      .replaceAll('×', 'x')
      .replaceAll('℮', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // Multipack : "6 x 125 g", "6x125g"
  final multi = RegExp(r'(\d+)\s*x\s*(\d+(?:\.\d+)?)\s*([a-z]+)').firstMatch(s);
  if (multi != null) {
    final n = int.tryParse(multi.group(1)!);
    final v = double.tryParse(multi.group(2)!);
    final u = _unites[multi.group(3)!];
    if (n != null && v != null && u != null) {
      final total = _arrondi(n * v * u.$3);
      return QuantiteOff(
        total,
        u.$1,
        u.$2,
        '$n × $v ${multi.group(3)} → $total ${u.$1}',
      );
    }
  }

  // Simple : "250 g", "1.5 l", "75 cl"
  final simple = RegExp(r'(\d+(?:\.\d+)?)\s*([a-z]+)').firstMatch(s);
  if (simple != null) {
    final v = double.tryParse(simple.group(1)!);
    final tok = simple.group(2)!;
    final u = _unites[tok];
    if (v != null && u != null) {
      final conv = _arrondi(v * u.$3);
      return QuantiteOff(
        conv,
        u.$1,
        u.$2,
        u.$3 == 1 ? '$v $tok' : '$v $tok → $conv ${u.$1}',
      );
    }
  }

  // Comptage : "6 pièces", "lot de 4", "x6"
  final pieces = RegExp(
    r'(?:lot de\s+|x\s*)(\d+)|(\d+)\s*(?:pi[eè]ces?|pcs|unit[eé]s?)',
  ).firstMatch(s);
  if (pieces != null) {
    final n = int.tryParse(pieces.group(1) ?? pieces.group(2) ?? '');
    if (n != null) {
      return QuantiteOff(n.toDouble(), 'pièce', TypeGrandeur.unite, '$n pièce(s)');
    }
  }

  return QuantiteOff(null, null, null, 'non reconnu : « $brut »');
}

double _arrondi(double v) => (v * 1000).round() / 1000;

// ─────────────────────────────────────────────────────────────────────────────
// Niveau de reconnaissance (confort utilisateur, cf. POC §5.8)
// ─────────────────────────────────────────────────────────────────────────────

enum NiveauReconnaissance { catalogueLocal, complet, partiel, aucun }

class ReconnaissanceProduit {
  final NiveauReconnaissance niveau;
  final bool nomTrouve;
  final bool categorieDeduite;
  final bool quantiteParsee;

  /// Messages courts, prêts à afficher (jamais de détail technique brut).
  final List<String> raisons;

  const ReconnaissanceProduit({
    required this.niveau,
    required this.nomTrouve,
    required this.categorieDeduite,
    required this.quantiteParsee,
    required this.raisons,
  });

  static const catalogueLocal = ReconnaissanceProduit(
    niveau: NiveauReconnaissance.catalogueLocal,
    nomTrouve: true,
    categorieDeduite: true,
    quantiteParsee: true,
    raisons: ['Produit déjà dans votre catalogue — rien à ressaisir.'],
  );
}

/// Construit l'indicateur à partir du résultat de la recherche en ligne.
ReconnaissanceProduit evaluerReconnaissance({
  required bool reseauDisponible,
  required bool offConnait,
  required String? nomOff,
  required String bucket,
  required List<String> tagsOff,
  required QuantiteOff quantite,
  required String? quantiteBrute,
}) {
  if (!reseauDisponible) {
    return const ReconnaissanceProduit(
      niveau: NiveauReconnaissance.aucun,
      nomTrouve: false,
      categorieDeduite: false,
      quantiteParsee: false,
      raisons: ['Pas de connexion — recherche en ligne impossible.'],
    );
  }
  if (!offConnait) {
    return const ReconnaissanceProduit(
      niveau: NiveauReconnaissance.aucun,
      nomTrouve: false,
      categorieDeduite: false,
      quantiteParsee: false,
      raisons: ["Ce code-barres n'est pas référencé dans Open Food Facts."],
    );
  }

  final nomTrouve = nomOff != null && nomOff.trim().isNotEmpty;
  final categorieDeduite = bucket != 'autre';
  final quantiteParsee = quantite.valeur != null;

  final raisons = <String>[];
  if (!nomTrouve) {
    raisons.add("Open Food Facts n'a pas de nom pour ce produit.");
  }
  if (!categorieDeduite) {
    raisons.add(
      tagsOff.isEmpty
          ? 'Aucune catégorie fournie par Open Food Facts.'
          : 'Catégorie non déduite automatiquement.',
    );
  }
  if (!quantiteParsee) {
    raisons.add(
      quantiteBrute == null
          ? 'Aucune quantité fournie par Open Food Facts.'
          : 'Format de quantité non reconnu : « $quantiteBrute ».',
    );
  }

  final complet = nomTrouve && categorieDeduite && quantiteParsee;
  return ReconnaissanceProduit(
    niveau: complet
        ? NiveauReconnaissance.complet
        : NiveauReconnaissance.partiel,
    nomTrouve: nomTrouve,
    categorieDeduite: categorieDeduite,
    quantiteParsee: quantiteParsee,
    raisons: complet
        ? const ['Nom, catégorie et quantité récupérés.']
        : raisons,
  );
}
