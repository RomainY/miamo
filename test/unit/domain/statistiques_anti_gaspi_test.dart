import 'package:flutter_test/flutter_test.dart';
import 'package:miamo/data/database/app_database.dart';
import 'package:miamo/data/database/tables.dart';
import 'package:miamo/data/repositories/produit_frigo_repository.dart';
import 'package:miamo/features/statistiques/domain/statistiques_anti_gaspi.dart';

HistoriqueStatutProduit _evenement({
  required int produitId,
  required StatutProduitFrigo statut,
  required DateTime dateStatut,
}) {
  return HistoriqueStatutProduit(
    produitId: produitId,
    statut: statut,
    dateStatut: dateStatut,
    quantite: 1,
    uniteId: 1,
  );
}

Produit _produit(int id, String nom) => Produit(
  id: id,
  nom: nom,
  categorieId: 1,
  typeGrandeur: TypeGrandeur.unite,
  uniteDefautId: 1,
  statut: StatutProduit.actif,
  dateDerniereUtilisation: null,
  codeBarre: null,
);

void main() {
  test('liste vide -> bilan vide, taux global à 0', () {
    final bilan = calculerBilanAntiGaspi(historique: const [], produitsParId: const {});

    expect(bilan.parMois, isEmpty);
    expect(bilan.topGaspillage, isEmpty);
    expect(bilan.tauxGaspillageGlobal, 0);
  });

  test('agrège par mois calendaire, un mois par entrée triée chronologiquement', () {
    final historique = [
      _evenement(produitId: 1, statut: StatutProduitFrigo.consomme, dateStatut: DateTime(2026, 7, 5)),
      _evenement(produitId: 1, statut: StatutProduitFrigo.jete, dateStatut: DateTime(2026, 7, 20)),
      _evenement(produitId: 2, statut: StatutProduitFrigo.consomme, dateStatut: DateTime(2026, 6, 1)),
    ];

    final bilan = calculerBilanAntiGaspi(
      historique: historique,
      produitsParId: {1: _produit(1, 'Lait'), 2: _produit(2, 'Riz')},
    );

    expect(bilan.parMois, hasLength(2));
    expect(bilan.parMois[0].mois, DateTime(2026, 6));
    expect(bilan.parMois[0].nbConsomme, 1);
    expect(bilan.parMois[0].nbJete, 0);
    expect(bilan.parMois[1].mois, DateTime(2026, 7));
    expect(bilan.parMois[1].nbConsomme, 1);
    expect(bilan.parMois[1].nbJete, 1);
    expect(bilan.parMois[1].tauxGaspillage, 0.5);
  });

  test('taux de gaspillage global sur toute la période', () {
    final historique = [
      _evenement(produitId: 1, statut: StatutProduitFrigo.consomme, dateStatut: DateTime(2026, 7, 1)),
      _evenement(produitId: 1, statut: StatutProduitFrigo.consomme, dateStatut: DateTime(2026, 7, 2)),
      _evenement(produitId: 1, statut: StatutProduitFrigo.consomme, dateStatut: DateTime(2026, 7, 3)),
      _evenement(produitId: 1, statut: StatutProduitFrigo.jete, dateStatut: DateTime(2026, 7, 4)),
    ];

    final bilan = calculerBilanAntiGaspi(
      historique: historique,
      produitsParId: {1: _produit(1, 'Lait')},
    );

    expect(bilan.nbConsommeTotal, 3);
    expect(bilan.nbJeteTotal, 1);
    expect(bilan.tauxGaspillageGlobal, 0.25);
  });

  test('top gaspillage trié par nombre de jeté décroissant', () {
    final historique = [
      _evenement(produitId: 1, statut: StatutProduitFrigo.jete, dateStatut: DateTime(2026, 7, 1)),
      _evenement(produitId: 2, statut: StatutProduitFrigo.jete, dateStatut: DateTime(2026, 7, 2)),
      _evenement(produitId: 2, statut: StatutProduitFrigo.jete, dateStatut: DateTime(2026, 7, 3)),
      _evenement(produitId: 2, statut: StatutProduitFrigo.jete, dateStatut: DateTime(2026, 7, 4)),
      _evenement(produitId: 3, statut: StatutProduitFrigo.consomme, dateStatut: DateTime(2026, 7, 5)),
    ];

    final bilan = calculerBilanAntiGaspi(
      historique: historique,
      produitsParId: {
        1: _produit(1, 'Épinards'),
        2: _produit(2, 'Yaourts'),
        3: _produit(3, 'Riz'),
      },
    );

    expect(bilan.topGaspillage, hasLength(2));
    expect(bilan.topGaspillage[0].produitNom, 'Yaourts');
    expect(bilan.topGaspillage[0].nbJete, 3);
    expect(bilan.topGaspillage[1].produitNom, 'Épinards');
    expect(bilan.topGaspillage[1].nbJete, 1);
  });

  test('un produit disparu du catalogue (supprimé définitivement) est omis du top', () {
    final historique = [
      _evenement(produitId: 99, statut: StatutProduitFrigo.jete, dateStatut: DateTime(2026, 7, 1)),
    ];

    final bilan = calculerBilanAntiGaspi(historique: historique, produitsParId: const {});

    // Le mois compte quand même l'occurrence...
    expect(bilan.parMois.single.nbJete, 1);
    // ...mais le produit, introuvable, n'apparaît pas dans le classement nommé.
    expect(bilan.topGaspillage, isEmpty);
  });
}
