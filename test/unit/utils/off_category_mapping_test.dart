import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/shared/utils/off_category_mapping.dart';

void main() {
  group('resolveBucket', () {
    test('rattache un yaourt à la crémerie via le tag le plus spécifique', () {
      final r = resolveBucket(const [
        'en:dairies',
        'en:fermented-foods',
        'en:fermented-milk-products',
        'en:yogurts',
      ]);
      expect(r.bucket, 'cremerie');
      expect(r.tagDeclencheur, 'en:yogurts');
    });

    test('rattache une eau à la famille boissons', () {
      final r = resolveBucket(const ['en:beverages', 'en:waters', 'en:spring-waters']);
      expect(r.bucket, 'boissons');
    });

    test('« autre » quand aucun tag ne correspond', () {
      final r = resolveBucket(const ['en:some-exotic-unmapped-tag']);
      expect(r.bucket, 'autre');
      expect(r.tagDeclencheur, isNull);
    });

    test('« autre » sur liste vide', () {
      expect(resolveBucket(const []).bucket, 'autre');
    });
  });

  group('mapperCategorie', () {
    test('trouve une catégorie existante via un alias (casse/accents ignorés)', () {
      final c = mapperCategorie('cremerie', const ['Épicerie', 'FRAIS', 'Boissons']);
      expect(c.categorieExistante, 'FRAIS');
    });

    test('propose le nom par défaut si aucune catégorie ne correspond', () {
      final c = mapperCategorie('cremerie', const ['Apéro', 'Bébé']);
      expect(c.categorieExistante, isNull);
      expect(c.nomAProposer, 'Frais');
    });

    test('bucket « autre » → propose « Non classé »', () {
      final c = mapperCategorie('autre', const ['Frais']);
      expect(c.categorieExistante, isNull);
      expect(c.nomAProposer, 'Non classé');
    });
  });

  group('parseQuantiteOff', () {
    test('volume simple avec conversion cl → millilitre', () {
      final q = parseQuantiteOff('75 cl');
      expect(q.valeur, 750);
      expect(q.uniteNom, 'millilitre');
      expect(q.typeGrandeur, TypeGrandeur.volume);
    });

    test('masse simple', () {
      final q = parseQuantiteOff('250 g');
      expect(q.valeur, 250);
      expect(q.uniteNom, 'gramme');
      expect(q.typeGrandeur, TypeGrandeur.masse);
    });

    test('litre avec virgule décimale', () {
      final q = parseQuantiteOff('1,5 L');
      expect(q.valeur, 1.5);
      expect(q.uniteNom, 'litre');
    });

    test('multipack « 6 x 125 g » → total 750 g', () {
      final q = parseQuantiteOff('6 x 125 g');
      expect(q.valeur, 750);
      expect(q.uniteNom, 'gramme');
    });

    test('comptage « lot de 4 » → 4 pièces', () {
      final q = parseQuantiteOff('lot de 4');
      expect(q.valeur, 4);
      expect(q.typeGrandeur, TypeGrandeur.unite);
    });

    test('format non reconnu → valeur nulle', () {
      expect(parseQuantiteOff('environ deux poignées').valeur, isNull);
      expect(parseQuantiteOff(null).valeur, isNull);
      expect(parseQuantiteOff('').valeur, isNull);
    });
  });

  group('evaluerReconnaissance', () {
    QuantiteOff ok() => const QuantiteOff(250, 'gramme', TypeGrandeur.masse, '');

    test('réseau indisponible → niveau aucun', () {
      final r = evaluerReconnaissance(
        reseauDisponible: false,
        offConnait: false,
        nomOff: null,
        bucket: 'autre',
        tagsOff: const [],
        quantite: QuantiteOff.nonReconnu,
        quantiteBrute: null,
      );
      expect(r.niveau, NiveauReconnaissance.aucun);
      expect(r.raisons.single, contains('connexion'));
    });

    test('code inconnu d\'OFF → niveau aucun', () {
      final r = evaluerReconnaissance(
        reseauDisponible: true,
        offConnait: false,
        nomOff: null,
        bucket: 'autre',
        tagsOff: const [],
        quantite: QuantiteOff.nonReconnu,
        quantiteBrute: null,
      );
      expect(r.niveau, NiveauReconnaissance.aucun);
      expect(r.raisons.single, contains('Open Food Facts'));
    });

    test('tout présent → complet', () {
      final r = evaluerReconnaissance(
        reseauDisponible: true,
        offConnait: true,
        nomOff: 'Yaourt nature',
        bucket: 'cremerie',
        tagsOff: const ['en:yogurts'],
        quantite: ok(),
        quantiteBrute: '250 g',
      );
      expect(r.niveau, NiveauReconnaissance.complet);
    });

    test('catégorie non déduite → partiel, avec raison', () {
      final r = evaluerReconnaissance(
        reseauDisponible: true,
        offConnait: true,
        nomOff: 'Truc',
        bucket: 'autre',
        tagsOff: const ['en:x'],
        quantite: ok(),
        quantiteBrute: '250 g',
      );
      expect(r.niveau, NiveauReconnaissance.partiel);
      expect(r.categorieDeduite, isFalse);
      expect(r.raisons.any((s) => s.contains('Catégorie')), isTrue);
    });

    test('quantité non parsée → partiel, avec la valeur brute dans la raison', () {
      final r = evaluerReconnaissance(
        reseauDisponible: true,
        offConnait: true,
        nomOff: 'Truc',
        bucket: 'cremerie',
        tagsOff: const ['en:yogurts'],
        quantite: QuantiteOff.nonReconnu,
        quantiteBrute: '6 x 125 g bidon',
      );
      expect(r.niveau, NiveauReconnaissance.partiel);
      expect(r.raisons.any((s) => s.contains('6 x 125 g bidon')), isTrue);
    });
  });
}
