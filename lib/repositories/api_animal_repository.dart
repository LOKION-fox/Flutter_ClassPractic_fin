import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../core/auth_service.dart';
import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/page_result.dart';
import 'animal_repository.dart';

class ApiAnimalRepository implements AnimalRepository {
  final ApiClient _api;
  final AuthService _auth;

  ApiAnimalRepository(this._api, this._auth);

  String? _filter(AnimalQuery query) {
    final parts = <String>[];
    final params = <String, dynamic>{};

    if (!query.includeDeleted) parts.add('deletedAt = ""');

    if (query.search.trim().isNotEmpty) {
      parts.add('(name ~ {:search} || breed ~ {:search} || country ~ {:search})');
      params['search'] = query.search.trim();
    }

    if (query.species != null) {
      parts.add('species = {:species}');
      params['species'] = query.species;
    }

    if (query.sex != null) {
      parts.add('sex = {:sex}');
      params['sex'] = query.sex;
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
  Future<PageResult<Animal>> find(AnimalQuery query) {
    return _api.run(() async {
      final sortField = query.sortField == 'age' ? 'ageMonths' : query.sortField;
      final result = await _api.pocketBase.collection('animals').getList(
            page: query.page,
            perPage: query.size,
            filter: _filter(query),
            sort: query.sortAscending ? sortField : '-$sortField',
          );

      return PageResult<Animal>(
        items: result.items.map((record) => Animal.fromJson(record.toJson())).toList(),
        page: result.page,
        size: result.perPage,
        total: result.totalItems,
      );
    });
  }

  @override
  Future<List<Animal>> all() {
    return _api.run(() async {
      final records = await _api.pocketBase.collection('animals').getFullList(sort: 'name');
      return records.map((record) => Animal.fromJson(record.toJson())).toList();
    });
  }

  @override
  Future<Animal?> findById(String id) async {
    try {
      return await _api.run(() async {
        final record = await _api.pocketBase.collection('animals').getOne(id);
        return Animal.fromJson(record.toJson());
      });
    } on NotFoundException {
      return null;
    }
  }

  @override
  Future<Animal> create(Animal animal) {
    return _auth.authorized(() => _api.run(() async {
          final record = await _api.pocketBase.collection('animals').create(body: animal.toJson());
          return Animal.fromJson(record.toJson());
        }));
  }

  @override
  Future<void> update(Animal animal) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('animals').update(animal.id, body: animal.toJson());
        }));
  }

  @override
  Future<void> softDelete(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('animals').update(
            id,
            body: {'deletedAt': DateTime.now().toUtc().toIso8601String()},
          );
        }));
  }

  @override
  Future<void> hardDelete(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('animals').delete(id);
        }));
  }

  @override
  Future<void> restore(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('animals').update(id, body: {'deletedAt': ''});
        }));
  }

  @override
  Future<int> deleteMany(List<String> ids) {
    return _auth.authorized(() => _api.run(() async {
          var count = 0;
          for (final id in ids) {
            await _api.pocketBase.collection('animals').update(
              id,
              body: {'deletedAt': DateTime.now().toUtc().toIso8601String()},
            );
            count++;
          }
          return count;
        }));
  }
}
