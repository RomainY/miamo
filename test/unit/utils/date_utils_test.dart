import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/shared/utils/date_utils.dart';

DateTime _dans(int jours) => DateTime.now().add(Duration(days: jours));

void main() {
  group('datesDeclenchementNotification', () {
    test('un rappel par jour de joursAvant jours avant jusqu\'au lendemain '
        'de la péremption inclus (règle corrigée le 07/09/2026)', () {
      final dates = datesDeclenchementNotification(
        DateTime(2026, 9, 10),
        maintenant: DateTime(2026, 9, 1),
      );
      // joursAvantNotification=2, heureNotification=9 par défaut : 8, 9, 10,
      // 11 septembre à 9h (2 avant + le jour J + le lendemain).
      expect(dates, [
        DateTime(2026, 9, 8, 9),
        DateTime(2026, 9, 9, 9),
        DateTime(2026, 9, 10, 9),
        DateTime(2026, 9, 11, 9),
      ]);
    });

    test('joursAvant=0 : seulement le jour J et le lendemain', () {
      final dates = datesDeclenchementNotification(
        DateTime(2026, 9, 10),
        maintenant: DateTime(2026, 9, 1),
        joursAvant: 0,
      );
      expect(dates, [DateTime(2026, 9, 10, 9), DateTime(2026, 9, 11, 9)]);
    });

    test('ne renvoie que les rappels pas encore passés', () {
      final dates = datesDeclenchementNotification(
        DateTime(2026, 9, 10),
        maintenant: DateTime(2026, 9, 9, 12), // après le rappel du 9 à 9h
      );
      expect(dates, [DateTime(2026, 9, 10, 9), DateTime(2026, 9, 11, 9)]);
    });

    test('liste vide si tous les rappels sont déjà passés', () {
      final dates = datesDeclenchementNotification(
        DateTime(2026, 9, 3),
        maintenant: DateTime(2026, 9, 10),
      );
      expect(dates, isEmpty);
    });

    test('joursAvant/heure réglables (écran Paramètres, v1.2) remplacent '
        'les valeurs par défaut', () {
      final dates = datesDeclenchementNotification(
        DateTime(2026, 9, 10),
        maintenant: DateTime(2026, 9, 1),
        joursAvant: 1,
        heure: 20,
      );
      expect(dates, [
        DateTime(2026, 9, 9, 20),
        DateTime(2026, 9, 10, 20),
        DateTime(2026, 9, 11, 20),
      ]);
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

  group('urgencePeremption', () {
    test('null quand il n\'y a pas de date de péremption', () {
      expect(urgencePeremption(null), isNull);
    });

    test('"Périmé" (rouge) pour une date passée', () {
      final u = urgencePeremption(_dans(-2))!;
      expect(u.label, 'Périmé');
      expect(u.color, const Color(0xFFC23B3B));
    });

    test('"Aujourd\'hui" pour une péremption le jour même', () {
      expect(urgencePeremption(_dans(0))!.label, "Aujourd'hui");
    });

    test('"J-n" pour 1 à 7 jours restants', () {
      expect(urgencePeremption(_dans(2))!.label, 'J-2');
      expect(urgencePeremption(_dans(6))!.label, 'J-6');
    });

    test('palier de couleur différent à <=3 j et à 4-7 j', () {
      expect(
        urgencePeremption(_dans(3))!.color,
        isNot(urgencePeremption(_dans(5))!.color),
      );
    });

    test('au-delà de 7 jours : date formatée jj/MM/aaaa', () {
      final cible = _dans(20);
      final u = urgencePeremption(cible)!;
      final attendu =
          '${cible.day.toString().padLeft(2, '0')}/'
          '${cible.month.toString().padLeft(2, '0')}/'
          '${cible.year}';
      expect(u.label, attendu);
    });
  });
}
