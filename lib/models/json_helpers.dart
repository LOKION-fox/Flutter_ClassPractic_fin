String jsonString(
  Map<String, dynamic> json,
  String key, {
  String fallback = '',
}) {
  final value = json[key];
  return value == null ? fallback : value.toString();
}

int jsonInt(Map<String, dynamic> json, String key, {int fallback = 0}) {
  final value = json[key];

  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double jsonDouble(
  Map<String, dynamic> json,
  String key, {
  double fallback = 0,
}) {
  final value = json[key];

  if (value is double) return value;
  if (value is num) return value.toDouble();

  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

List<String> jsonStringList(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value is! List) {
    return const [];
  }

  return value
      .where((item) => item != null)
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList();
}

DateTime? jsonDate(Map<String, dynamic> json, String key) {
  final value = json[key];

  if (value == null || value.toString().trim().isEmpty) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}
