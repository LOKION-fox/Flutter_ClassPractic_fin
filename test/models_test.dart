import 'package:flutter_test/flutter_test.dart';

import 'package:pet_shop_web/models/app_role.dart';
import 'package:pet_shop_web/models/app_user.dart';
import 'package:pet_shop_web/models/product.dart';

void main() {
  test('Product разбирает связи PocketBase из JSON', () {
    final product = Product.fromJson({
      'id': 'prod00000000010',
      'name': 'Игрушка',
      'article': 'T-10',
      'brand': 'Test',
      'price': 500,
      'stock': 3,
      'supplierId': 'supp00000000007',
      'categoryIds': ['cat00000000002'],
      'description': 'Описание',
      'deletedAt': '',
    });

    expect(product.id, 'prod00000000010');
    expect(product.supplierId, 'supp00000000007');
    expect(product.categoryIds, ['cat00000000002']);
  });

  test('Product безопасно разбирает отсутствующие поля', () {
    final product = Product.fromJson({'id': 'prod00000000001'});

    expect(product.name, '');
    expect(product.article, '');
    expect(product.categoryIds, isEmpty);
    expect(product.supplierId, '');
  });

  test('AppUser разбирает роль администратора', () {
    final user = AppUser.fromJson({
      'id': 'user00000000003',
      'username': 'admin',
      'fullName': 'Администратор',
      'role': 'admin',
    });

    expect(user.role, AppRole.admin);
    expect(user.username, 'admin');
  });

  test('неизвестная роль безопасно превращается в customer', () {
    final user = AppUser.fromJson({'role': 'unknown'});
    expect(user.role, AppRole.customer);
  });
}
