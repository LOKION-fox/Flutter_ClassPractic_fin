import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../core/auth_service.dart';
import '../models/page_result.dart';
import '../models/simple_query.dart';
import '../models/supplier.dart';
import 'supplier_repository.dart';

class ApiSupplierRepository implements SupplierRepository {
  final ApiClient _api;
  final AuthService _auth;
  List<Supplier>? _cache;
  DateTime? _cacheTime;

  ApiSupplierRepository(this._api, this._auth);

  bool get _cacheIsValid =>
      _cache != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!).inMinutes < 5;

  void _clearCache() {
    _cache = null;
    _cacheTime = null;
  }

  String? _filter(SimpleQuery query) {
    final parts = <String>[];
    final params = <String, dynamic>{};

    if (!query.includeDeleted) parts.add('deletedAt = ""');

    if (query.search.trim().isNotEmpty) {
      parts.add('(name ~ {:search} || country ~ {:search} || email ~ {:search})');
      params['search'] = query.search.trim();
    }

    if (query.filter != null) {
      parts.add('country = {:country}');
      params['country'] = query.filter;
    }

    if (parts.isEmpty) return null;
    return _api.filter(parts.join(' && '), params);
  }

  @override
  Future<PageResult<Supplier>> find(SimpleQuery query) {
    return _api.run(() async {
      final result = await _api.pocketBase.collection('suppliers').getList(
            page: query.page,
            perPage: query.size,
            filter: _filter(query),
            sort: query.sortAscending ? query.sortField : '-${query.sortField}',
          );

      return PageResult<Supplier>(
        items: result.items.map((record) => Supplier.fromJson(record.toJson())).toList(),
        page: result.page,
        size: result.perPage,
        total: result.totalItems,
      );
    });
  }

  @override
  Future<List<Supplier>> all() async {
    if (_cacheIsValid) return [..._cache!];

    final result = await _api.run(() async {
      final records = await _api.pocketBase.collection('suppliers').getFullList(sort: 'name');
      return records.map((record) => Supplier.fromJson(record.toJson())).toList();
    });

    _cache = result;
    _cacheTime = DateTime.now();
    return [...result];
  }

  @override
  Future<Supplier?> findById(String id) async {
    try {
      return await _api.run(() async {
        final record = await _api.pocketBase.collection('suppliers').getOne(id);
        return Supplier.fromJson(record.toJson());
      });
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<Supplier> create(Supplier supplier) {
    return _auth.authorized(() => _api.run(() async {
          final record = await _api.pocketBase.collection('suppliers').create(body: supplier.toJson());
          _clearCache();
          return Supplier.fromJson(record.toJson());
        }));
  }

  @override
  Future<void> update(Supplier supplier) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('suppliers').update(supplier.id, body: supplier.toJson());
          _clearCache();
        }));
  }

  @override
  Future<void> softDelete(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('suppliers').update(
            id,
            body: {'deletedAt': DateTime.now().toUtc().toIso8601String()},
          );
          _clearCache();
        }));
  }

  @override
  Future<void> hardDelete(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('suppliers').delete(id);
          _clearCache();
        }));
  }

  @override
  Future<void> restore(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('suppliers').update(id, body: {'deletedAt': ''});
          _clearCache();
        }));
  }

  @override
  Future<int> deleteMany(List<String> ids) {
    return _auth.authorized(() => _api.run(() async {
          var count = 0;
          for (final id in ids) {
            await _api.pocketBase.collection('suppliers').update(
              id,
              body: {'deletedAt': DateTime.now().toUtc().toIso8601String()},
            );
            count++;
          }
          _clearCache();
          return count;
        }));
  }
}
