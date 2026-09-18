import '../models/app_user.dart';
import 'api_client.dart';
import 'api_exceptions.dart';

class AuthService {
  final ApiClient api;

  AuthService(this.api);

  bool get isAuthorized =>
      api.pocketBase.authStore.isValid && api.pocketBase.authStore.record != null;

  String? get token {
    final value = api.pocketBase.authStore.token;
    return value.isEmpty ? null : value;
  }

  AppUser? get currentUser {
    final record = api.pocketBase.authStore.record;

    if (record == null) {
      return null;
    }

    return AppUser.fromJson(record.toJson());
  }

  Future<AppUser> login(
    String username,
    String password,
  ) {
    return api.run(
      () async {
        final result = await api.pocketBase
            .collection('users')
            .authWithPassword(username.trim(), password);

        return AppUser.fromJson(result.record.toJson());
      },
    );
  }

  Future<AppUser> register({
    required String username,
    required String fullName,
    required String password,
  }) {
    return api.run(
      () async {
        final record = await api.pocketBase.collection('users').create(
          body: {
            'username': username.trim(),
            'fullName': fullName.trim(),
            'role': 'customer',
            'password': password,
            'passwordConfirm': password,
          },
        );

        return AppUser.fromJson(record.toJson());
      },
    );
  }

  Future<AppUser> refresh() {
    return api.run(
      () async {
        final result = await api.pocketBase.collection('users').authRefresh();
        return AppUser.fromJson(result.record.toJson());
      },
    );
  }

  Future<AppUser> me() async {
    if (!isAuthorized) {
      throw const UnauthorizedException(
        'Сессия отсутствует или истекла.',
      );
    }

    return refresh();
  }

  Future<void> logout() async {
    api.pocketBase.authStore.clear();
  }

  Future<T> authorized<T>(
    Future<T> Function() action,
  ) {
    if (!isAuthorized) {
      throw const UnauthorizedException(
        'Для выполнения операции необходимо войти в систему.',
      );
    }

    return action();
  }
}
