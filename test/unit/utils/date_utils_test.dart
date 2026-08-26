import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/shared/utils/date_utils.dart';

void main() {
  group('dateDeclenchementNotification', () {
    test(
      'programme la notification joursAvantNotification jours avant, '
      'à heureNotification h',
      () {
        final declenchement = dateDeclenchementNotification(
          DateTime(2026, 9, 10),
          maintenant: DateTime(2026, 9, 1),
        );
        expect(declenchement, DateTime(2026, 9, 8, 9));
      },
    );

    test('retourne null si le déclenchement est déjà passé', () {
      final declenchement = dateDeclenchementNotification(
        DateTime(2026, 9, 3),
        maintenant: DateTime(2026, 9, 5),
      );
      expect(declenchement, isNull);
    });

    test('retourne null pour une péremption trop proche (déclenchement déjà '
        "passé aujourd'hui)", () {
      final declenchement = dateDeclenchementNotification(
        DateTime(2026, 9, 5),
        maintenant: DateTime(2026, 9, 4, 10),
      );
      expect(declenchement, isNull);
    });
  });

  group('joursRestants', () {
    test('calcule un delta positif pour une date future', () {
      final dansTroisJours = DateTime.now().add(const Duration(days: 3));
      expect(joursRestants(dansTroisJours), 3);
    });

    test('calcule un delta négatif pour une date passée', () {
      final hier = DateTime.now().subtract(const Duration(days: 1));
      expect(joursRestants(hier), -1);
    });
  });
}
