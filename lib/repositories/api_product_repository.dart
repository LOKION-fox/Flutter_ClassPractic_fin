import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../core/auth_service.dart';
import '../models/page_result.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import 'product_repository.dart';

class ApiProductRepository implements ProductRepository {
  final ApiClient _api;
  final AuthService _auth;

  ApiProductRepository(this._api, this._auth);

  String? _filter(ProductQuery query) {
    final parts = <String>[];
    final params = <String, dynamic>{};

    if (!query.includeDeleted) {
      parts.add('deletedAt = ""');
    }

    if (query.search.trim().isNotEmpty) {
      parts.add('(name ~ {:search} || article ~ {:search} || brand ~ {:search})');
      params['search'] = query.search.trim();
    }

    if (query.categoryId != null) {
      parts.add('categoryIds ?= {:categoryId}');
      params['categoryId'] = query.categoryId;
    }

    if (query.supplierId != null) {
      parts.add('supplierId = {:supplierId}');
      params['supplierId'] = query.supplierId;
    }

    if (query.priceFrom != null) {
      parts.add('price >= {:priceFrom}');
      params['priceFrom'] = query.priceFrom;
    }

    if (query.priceTo != null) {
      parts.add('price <= {:priceTo}');
      params['priceTo'] = query.priceTo;
    }

    if (parts.isEmpty) return null;
    return _api.filter(parts.join(' && '), params);
  }

  @override
  Future<PageResult<Product>> find(ProductQuery query) {
    return _api.run(() async {
      final result = await _api.pocketBase.collection('products').getList(
            page: query.page,
            perPage: query.size,
            filter: _filter(query),
            sort: query.sortAscending ? query.sortField : '-${query.sortField}',
          );

      return PageResult<Product>(
        items: result.items.map((record) => Product.fromJson(record.toJson())).toList(),
        page: result.page,
        size: result.perPage,
        total: result.totalItems,
      );
    });
  }

  @override
  Future<List<Product>> all() {
    return _api.run(() async {
      final records = await _api.pocketBase.collection('products').getFullList(sort: 'name');
      return records.map((record) => Product.fromJson(record.toJson())).toList();
    });
  }

  @override
  Future<Product?> findById(String id) async {
    try {
      return await _api.run(() async {
        final record = await _api.pocketBase.collection('products').getOne(id);
        return Product.fromJson(record.toJson());
      });
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<Product> create(Product product) {
    return _auth.authorized(() => _api.run(() async {
          final record = await _api.pocketBase.collection('products').create(body: product.toJson());
          return Product.fromJson(record.toJson());
        }));
  }

  @override
  Future<void> update(Product product) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('products').update(product.id, body: product.toJson());
        }));
  }

  @override
  Future<void> softDelete(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('products').update(
            id,
            body: {'deletedAt': DateTime.now().toUtc().toIso8601String()},
          );
        }));
  }

  @override
  Future<void> hardDelete(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('products').delete(id);
        }));
  }

  @override
  Future<void> restore(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('products').update(id, body: {'deletedAt': ''});
        }));
  }

  @override
  Future<int> deleteMany(List<String> ids) {
    return _auth.authorized(() => _api.run(() async {
          var count = 0;
          for (final id in ids) {
            await _api.pocketBase.collection('products').update(
              id,
              body: {'deletedAt': DateTime.now().toUtc().toIso8601String()},
            );
            count++;
          }
          return count;
        }));
  }
}
