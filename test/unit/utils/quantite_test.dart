import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/shared/utils/quantite.dart';

void main() {
  group('parseQuantite', () {
    test('accepte un entier, un décimal, la virgule et les espaces', () {
      expect(parseQuantite('250'), 250);
      expect(parseQuantite('1.5'), 1.5);
      expect(parseQuantite('1,5'), 1.5);
      expect(parseQuantite('  2  '), 2);
    });

    test('rejette vide / non numérique', () {
      expect(parseQuantite(''), isNull);
      expect(parseQuantite('   '), isNull);
      expect(parseQuantite('abc'), isNull);
      expect(parseQuantite('1,,5'), isNull);
    });

    test('rejette zéro et les valeurs négatives', () {
      expect(parseQuantite('0'), isNull);
      expect(parseQuantite('0,0'), isNull);
      expect(parseQuantite('-3'), isNull);
    });

    test('rejette infini / NaN', () {
      expect(parseQuantite('1e400'), isNull); // overflow -> Infinity
      expect(parseQuantite('NaN'), isNull);
    });
  });
}
