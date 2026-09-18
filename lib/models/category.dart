import 'json_helpers.dart';

class Category {
  final String id;
  final String name;
  final String kind;
  final String description;
  final DateTime? deletedAt;

  const Category({
    required this.id,
    required this.name,
    required this.kind,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Category copyWith({
    String? id,
    String? name,
    String? kind,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      description: description ?? this.description,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'kind': kind, 'description': description};
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: jsonString(json, 'id'),
      name: jsonString(json, 'name'),
      kind: jsonString(json, 'kind', fallback: 'product'),
      description: jsonString(json, 'description'),
      deletedAt: jsonDate(json, 'deletedAt'),
    );
  }
}
