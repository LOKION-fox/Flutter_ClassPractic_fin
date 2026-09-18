import '../core/api_client.dart';
import '../core/auth_service.dart';
import '../models/app_role.dart';
import '../models/app_user.dart';
import 'user_admin_repository.dart';

class ApiUserAdminRepository implements UserAdminRepository {
  final ApiClient _api;
  final AuthService _auth;

  ApiUserAdminRepository(this._api, this._auth);

  @override
  Future<List<AppUser>> findUsers() {
    return _auth.authorized(
      () => _api.run(() async {
        final records = await _api.pocketBase
            .collection('users')
            .getFullList(sort: 'username');
        return records
            .map((record) => AppUser.fromJson(record.toJson()))
            .toList();
      }),
    );
  }

  @override
  Future<AppUser> changeRole(String userId, AppRole role) {
    return _auth.authorized(
      () => _api.run(() async {
        final record = await _api.pocketBase
            .collection('users')
            .update(userId, body: {'role': role.value});
        return AppUser.fromJson(record.toJson());
      }),
    );
  }

  Future<int> _count(String collection, {String? filter}) async {
    final result = await _api.pocketBase
        .collection(collection)
        .getList(page: 1, perPage: 1, filter: filter);
    return result.totalItems;
  }

  @override
  Future<Map<String, int>> getStatistics() {
    return _auth.authorized(
      () => _api.run(() async {
        const active = 'deletedAt = ""';
        const deleted = 'deletedAt != ""';

        return {
          'products': await _count('products', filter: active),
          'animals': await _count('animals', filter: active),
          'categories': await _count('categories', filter: active),
          'suppliers': await _count('suppliers', filter: active),
          'customers': await _count('customers', filter: active),
          'users': await _count('users', filter: active),
          'deletedProducts': await _count('products', filter: deleted),
          'deletedAnimals': await _count('animals', filter: deleted),
        };
      }),
    );
  }
}
