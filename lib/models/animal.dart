import 'json_helpers.dart';

class Animal {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int ageMonths;
  final String sex;
  final String country;
  final double price;
  final String supplierId;
  final List<String> categoryIds;
  final String description;
  final DateTime? deletedAt;

  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.ageMonths,
    required this.sex,
    required this.country,
    required this.price,
    required this.supplierId,
    required this.categoryIds,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Animal copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    int? ageMonths,
    String? sex,
    String? country,
    double? price,
    String? supplierId,
    List<String>? categoryIds,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      ageMonths: ageMonths ?? this.ageMonths,
      sex: sex ?? this.sex,
      country: country ?? this.country,
      price: price ?? this.price,
      supplierId: supplierId ?? this.supplierId,
      categoryIds: categoryIds ?? this.categoryIds,
      description: description ?? this.description,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'ageMonths': ageMonths,
      'sex': sex,
      'country': country,
      'price': price,
      'supplierId': supplierId,
      'categoryIds': categoryIds,
      'description': description,
    };
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: jsonString(json, 'id'),
      name: jsonString(json, 'name'),
      species: jsonString(json, 'species'),
      breed: jsonString(json, 'breed'),
      ageMonths: jsonInt(json, 'ageMonths'),
      sex: jsonString(json, 'sex'),
      country: jsonString(json, 'country'),
      price: jsonDouble(json, 'price'),
      supplierId: jsonString(json, 'supplierId'),
      categoryIds: jsonStringList(json, 'categoryIds'),
      description: jsonString(json, 'description'),
      deletedAt: jsonDate(json, 'deletedAt'),
    );
  }
}
