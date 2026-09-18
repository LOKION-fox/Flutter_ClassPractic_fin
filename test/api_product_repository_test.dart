import 'package:flutter_test/flutter_test.dart';

import 'package:pet_shop_web/models/product.dart';
import 'package:pet_shop_web/models/product_query.dart';

void main() {
  test('Product разбирает PocketBase relation id', () {
    final product = Product.fromJson({
      'id': 'prod00000000001',
      'name': 'Игрушка',
      'article': 'T-1',
      'brand': 'Trixie',
      'price': 500,
      'stock': 3,
      'supplierId': 'supp00000000007',
      'categoryIds': ['cat00000000002'],
      'description': 'Описание',
      'deletedAt': '',
    });

    expect(product.id, 'prod00000000001');
    expect(product.supplierId, 'supp00000000007');
    expect(product.categoryIds, ['cat00000000002']);
    expect(product.isDeleted, false);
  });

  test('Product.toJson формирует тело PocketBase', () {
    const product = Product(
      id: '',
      name: 'Новый товар',
      article: 'NEW-001',
      brand: 'Brand',
      price: 900,
      stock: 10,
      supplierId: 'supp00000000001',
      categoryIds: ['cat00000000001'],
      description: 'Описание',
    );

    final json = product.toJson();

    expect(json['supplierId'], 'supp00000000001');
    expect(json['categoryIds'], ['cat00000000001']);
    expect(json.containsKey('id'), false);
  });

  test('ProductQuery сохраняет строковые id в URL', () {
    const query = ProductQuery(
      categoryId: 'cat00000000001',
      supplierId: 'supp00000000001',
      page: 2,
      size: 25,
    );

    final location = query.toLocation('/products');
    final parsed = ProductQuery.fromUri(Uri.parse(location));

    expect(parsed.categoryId, 'cat00000000001');
    expect(parsed.supplierId, 'supp00000000001');
    expect(parsed.page, 2);
    expect(parsed.size, 25);
  });
}
