import 'json_helpers.dart';

class Supplier {
  final String id;
  final String name;
  final String country;
  final String email;
  final List<String> allowedCategoryIds;
  final DateTime? deletedAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.country,
    required this.email,
    required this.allowedCategoryIds,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Supplier copyWith({
    String? id,
    String? name,
    String? country,
    String? email,
    List<String>? allowedCategoryIds,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      email: email ?? this.email,
      allowedCategoryIds: allowedCategoryIds ?? this.allowedCategoryIds,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'email': email,
      'allowedCategoryIds': allowedCategoryIds,
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: jsonString(json, 'id'),
      name: jsonString(json, 'name'),
      country: jsonString(json, 'country'),
      email: jsonString(json, 'email'),
      allowedCategoryIds: jsonStringList(json, 'allowedCategoryIds'),
      deletedAt: jsonDate(json, 'deletedAt'),
    );
  }
}
