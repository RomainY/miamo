import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/shared/utils/dropdown.dart';

void main() {
  group('valeurDropdownValide', () {
    test('renvoie la valeur quand elle figure dans la liste', () {
      expect(valeurDropdownValide(2, [1, 2, 3]), 2);
    });

    test('renvoie null quand la valeur est absente de la liste', () {
      // Cas du stream Drift pas encore ré-émis après création d'une entrée :
      // l'id sélectionné n'a pas encore d'item correspondant.
      expect(valeurDropdownValide(9, [1, 2, 3]), isNull);
    });

    test('renvoie null quand la valeur est null', () {
      expect(valeurDropdownValide(null, [1, 2, 3]), isNull);
    });

    test('renvoie null quand la liste est vide', () {
      expect(valeurDropdownValide(1, const <int>[]), isNull);
    });
  });
}
