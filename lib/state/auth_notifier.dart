import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_config.dart';
import '../core/api_exceptions.dart';
import '../core/auth_service.dart';
import '../models/app_role.dart';
import '../models/app_user.dart';

class AuthNotifier extends ChangeNotifier {
  static const _userKey = 'auth_user';

  // Значение используется только для отображения интерфейса.
  // Серверные права всегда проверяются правилами PocketBase.
  static const _uiRoleKey = 'auth_ui_role';

  static const _sessionStartedKey = 'auth_session_started';
  static const _lastActivityKey = 'auth_last_activity';

  final SharedPreferences _prefs;
  final AuthService _api;

  AppUser? _user;
  AppRole? _uiRole;

  DateTime? _sessionStartedAt;
  DateTime? _lastActivityAt;

  String? _notice;
  Future<bool>? _refreshFuture;
  DateTime? _lastActivitySavedAt;

  AuthNotifier(
    this._prefs,
    this._api,
  );

  AppUser? get user => _user;
  AppRole? get uiRole => _uiRole;
  String? get accessToken => _api.token;
  String? get notice => _notice;
  DateTime? get sessionStartedAt => _sessionStartedAt;
  DateTime? get lastActivityAt => _lastActivityAt;

  bool get isAuthenticated => _user != null && _api.isAuthorized;

  bool isUiRole(AppRole role) => _uiRole == role;

  bool can(AppPermission permission) {
    final role = _uiRole;

    if (role == null) {
      return false;
    }

    return roleHasPermission(role, permission);
  }

  void clearNotice() {
    _notice = null;
  }

  Future<void> restore() async {
    if (!_api.isAuthorized) {
      return;
    }

    final cachedUser = _prefs.getString(_userKey);

    if (cachedUser != null) {
      try {
        _user = AppUser.fromJson(
          Map<String, dynamic>.from(
            jsonDecode(cachedUser) as Map,
          ),
        );
      } catch (_) {
        _user = _api.currentUser;
      }
    } else {
      _user = _api.currentUser;
    }

    _uiRole = tryParseRole(_prefs.getString(_uiRoleKey)) ?? _user?.role;

    final startedMs = _prefs.getInt(_sessionStartedKey);
    final activityMs = _prefs.getInt(_lastActivityKey);

    if (startedMs != null) {
      _sessionStartedAt = DateTime.fromMillisecondsSinceEpoch(startedMs);
    }

    if (activityMs != null) {
      _lastActivityAt = DateTime.fromMillisecondsSinceEpoch(activityMs);
    }

    final now = DateTime.now();

    if (_sessionStartedAt != null &&
        now.difference(_sessionStartedAt!) >=
            const Duration(seconds: ApiConfig.maxSessionSeconds)) {
      await forceLogout('Максимальное время сессии истекло.');
      return;
    }

    if (_lastActivityAt != null &&
        now.difference(_lastActivityAt!) >=
            const Duration(seconds: ApiConfig.inactivitySeconds)) {
      await forceLogout('Сессия завершена из-за неактивности.');
      return;
    }

    try {
      _user = await _api.me();
      await _saveUser();
    } on UnauthorizedException {
      await forceLogout('Сессия истекла. Войдите снова.');
      return;
    } on ApiException {
      // Если сервер временно недоступен, оставляем валидную локальную
      // PocketBase-сессию и данные пользователя из AsyncAuthStore.
      _user ??= _api.currentUser;
    }

    if (_user == null || !_api.isAuthorized) {
      await forceLogout('Сессия истекла. Войдите снова.');
      return;
    }

    _uiRole ??= _user!.role;

    if (_sessionStartedAt == null) {
      _sessionStartedAt = DateTime.now();
      await _prefs.setInt(
        _sessionStartedKey,
        _sessionStartedAt!.millisecondsSinceEpoch,
      );
    }

    if (_lastActivityAt == null) {
      _lastActivityAt = DateTime.now();
      await _prefs.setInt(
        _lastActivityKey,
        _lastActivityAt!.millisecondsSinceEpoch,
      );
    }

    notifyListeners();
  }

  Future<void> login(
    String username,
    String password,
  ) async {
    final user = await _api.login(username, password);
    await _applyNewLogin(user);
  }

  Future<void> register({
    required String username,
    required String fullName,
    required String password,
  }) async {
    await _api.register(
      username: username,
      fullName: fullName,
      password: password,
    );

    await login(username, password);
  }

  Future<void> _applyNewLogin(AppUser user) async {
    _user = user;
    _uiRole = user.role;
    _sessionStartedAt = DateTime.now();
    _lastActivityAt = DateTime.now();
    _notice = null;

    await _prefs.setString(_uiRoleKey, user.role.value);
    await _saveUser();
    await _prefs.setInt(
      _sessionStartedKey,
      _sessionStartedAt!.millisecondsSinceEpoch,
    );
    await _prefs.setInt(
      _lastActivityKey,
      _lastActivityAt!.millisecondsSinceEpoch,
    );

    notifyListeners();
  }

  Future<bool> refreshTokens() {
    final running = _refreshFuture;

    if (running != null) {
      return running;
    }

    final future = _refreshTokensInternal();
    _refreshFuture = future;

    future.whenComplete(() {
      _refreshFuture = null;
    });

    return future;
  }

  Future<bool> _refreshTokensInternal() async {
    if (!_api.isAuthorized) {
      await forceLogout('Сессия истекла. Войдите снова.');
      return false;
    }

    try {
      _user = await _api.refresh();
      await _saveUser();
      notifyListeners();
      return true;
    } catch (_) {
      await forceLogout('Сессия истекла. Войдите снова.');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Локальная сессия всё равно очищается ниже.
    }

    await _clearSession();
    notifyListeners();
  }

  Future<void> forceLogout(String message) async {
    _notice = message;

    try {
      await _api.logout();
    } catch (_) {}

    await _clearSession();
    notifyListeners();
  }

  Future<void> _clearSession() async {
    _user = null;
    _uiRole = null;
    _sessionStartedAt = null;
    _lastActivityAt = null;

    await _prefs.remove(_userKey);
    await _prefs.remove(_uiRoleKey);
    await _prefs.remove(_sessionStartedKey);
    await _prefs.remove(_lastActivityKey);
  }

  Future<void> _saveUser() async {
    final value = _user;

    if (value == null) {
      return;
    }

    await _prefs.setString(
      _userKey,
      jsonEncode(value.toJson()),
    );
  }

  void recordActivity() {
    if (!isAuthenticated) {
      return;
    }

    final now = DateTime.now();
    _lastActivityAt = now;

    final previous = _lastActivitySavedAt;

    if (previous == null ||
        now.difference(previous) >= const Duration(seconds: 5)) {
      _lastActivitySavedAt = now;
      _prefs.setInt(_lastActivityKey, now.millisecondsSinceEpoch);
    }
  }
}
