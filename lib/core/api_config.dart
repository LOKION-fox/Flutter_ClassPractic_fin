class ApiConfig {
  // Локально используется PocketBase на 8090.
  // На GitHub Pages значение передаётся через
  // --dart-define=POCKETBASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'http://127.0.0.1:8090',
  );

  // По заданию ПР5: выход через 3 минуты бездействия.
  static const int inactivitySeconds = int.fromEnvironment(
    'SESSION_INACTIVITY_SECONDS',
    defaultValue: 180,
  );

  // Предупреждение за 30 секунд.
  static const int warningSeconds = int.fromEnvironment(
    'SESSION_WARNING_SECONDS',
    defaultValue: 30,
  );

  // Максимальная длительность сессии — 30 минут.
  static const int maxSessionSeconds = int.fromEnvironment(
    'SESSION_MAX_SECONDS',
    defaultValue: 1800,
  );
}
