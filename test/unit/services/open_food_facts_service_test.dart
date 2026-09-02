import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:miamo/shared/services/open_food_facts_service.dart';

OpenFoodFactsService _service(
  Future<http.Response> Function(http.Request request) handler,
) {
  return HttpOpenFoodFactsService(client: MockClient(handler));
}

void main() {
  test('n\'envoie que le code-barres, en HTTPS, avec un User-Agent', () async {
    late Uri vue;
    late String userAgent;
    final service = _service((req) async {
      vue = req.url;
      userAgent = req.headers['User-Agent'] ?? '';
      return http.Response('{"status":0}', 200);
    });

    await service.rechercher('3033710065967');

    expect(vue.scheme, 'https');
    expect(vue.host, 'world.openfoodfacts.org');
    expect(vue.path, '/api/v2/product/3033710065967.json');
    expect(userAgent, contains('Miamo'));
    // Aucune donnée personnelle dans l'URL.
    expect(vue.query, isNot(contains('@')));
  });

  test('status 1 + product → trouve, champs mappés (nom FR prioritaire)', () async {
    final service = _service((req) async {
      return http.Response(
        '{"status":1,"product":{'
        '"product_name":"Coffee","product_name_fr":"Café Grand-Mère",'
        '"categories_tags":["en:beverages","en:coffees"],'
        '"quantity":"250 g"}}',
        200,
      );
    });

    final r = await service.rechercher('3033710065967');
    expect(r.statut, OffStatut.trouve);
    expect(r.produit!.nom, 'Café Grand-Mère');
    expect(r.produit!.categoriesTags, ['en:beverages', 'en:coffees']);
    expect(r.produit!.quantiteBrute, '250 g');
  });

  test('status 0 → inconnu', () async {
    final service = _service((_) async => http.Response('{"status":0}', 200));
    expect((await service.rechercher('000')).statut, OffStatut.inconnu);
  });

  test('HTTP 404 → inconnu', () async {
    final service = _service((_) async => http.Response('', 404));
    expect((await service.rechercher('123')).statut, OffStatut.inconnu);
  });

  test('HTTP 500 → indisponible', () async {
    final service = _service((_) async => http.Response('oops', 500));
    expect((await service.rechercher('123')).statut, OffStatut.indisponible);
  });

  test('corps illisible → indisponible', () async {
    final service = _service((_) async => http.Response('<html>nope', 200));
    expect((await service.rechercher('123')).statut, OffStatut.indisponible);
  });

  test('exception réseau → indisponible (ne propage jamais)', () async {
    final service = _service((_) async => throw http.ClientException('boom'));
    expect((await service.rechercher('123')).statut, OffStatut.indisponible);
  });

  test('timeout → indisponible', () async {
    final service = HttpOpenFoodFactsService(
      client: MockClient((_) => Future.delayed(
            const Duration(milliseconds: 200),
            () => http.Response('{"status":1,"product":{}}', 200),
          )),
      timeout: const Duration(milliseconds: 20),
    );
    expect((await service.rechercher('123')).statut, OffStatut.indisponible);
  });
}
