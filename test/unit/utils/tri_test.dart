import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/shared/utils/tri.dart';

void main() {
  List<String> trier(List<String> valeurs) =>
      [...valeurs]..sort(comparerAlphabetique);

  test('insensible aux accents : é / È / e au même niveau', () {
    expect(
      trier(['Enclos', 'élan', 'Eau', 'êtres', 'edam']),
      ['Eau', 'edam', 'élan', 'Enclos', 'êtres'],
    );
  });

  test('insensible à la casse', () {
    expect(trier(['banane', 'Ananas', 'cerise']), [
      'Ananas',
      'banane',
      'cerise',
    ]);
  });

  test('les accentués ne sont pas rejetés après « z »', () {
    expect(trier(['zébu', 'Œuf', 'avocat', 'Épinard']), [
      'avocat',
      'Épinard',
      'Œuf',
      'zébu',
    ]);
  });

  test('départage déterministe quand les clés repliées sont égales', () {
    final r = comparerAlphabetique('Ete', 'Été');
    expect(r, isNot(0));
    expect(comparerAlphabetique('Été', 'Ete'), -r);
  });

  test('ç et c au même niveau', () {
    expect(trier(['Cyprès', 'ça', 'cume']), ['ça', 'cume', 'Cyprès']);
  });
}
