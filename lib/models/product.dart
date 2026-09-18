import 'json_helpers.dart';

class Product {
  final String id;
  final String name;
  final String article;
  final String brand;
  final double price;
  final int stock;
  final String supplierId;
  final List<String> categoryIds;
  final String description;
  final DateTime? deletedAt;

  const Product({
    required this.id,
    required this.name,
    required this.article,
    required this.brand,
    required this.price,
    required this.stock,
    required this.supplierId,
    required this.categoryIds,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Product copyWith({
    String? id,
    String? name,
    String? article,
    String? brand,
    double? price,
    int? stock,
    String? supplierId,
    List<String>? categoryIds,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      article: article ?? this.article,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      supplierId: supplierId ?? this.supplierId,
      categoryIds: categoryIds ?? this.categoryIds,
      description: description ?? this.description,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'article': article,
      'brand': brand,
      'price': price,
      'stock': stock,
      'supplierId': supplierId,
      'categoryIds': categoryIds,
      'description': description,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: jsonString(json, 'id'),
      name: jsonString(json, 'name'),
      article: jsonString(json, 'article'),
      brand: jsonString(json, 'brand'),
      price: jsonDouble(json, 'price'),
      stock: jsonInt(json, 'stock'),
      supplierId: jsonString(json, 'supplierId'),
      categoryIds: jsonStringList(json, 'categoryIds'),
      description: jsonString(json, 'description'),
      deletedAt: jsonDate(json, 'deletedAt'),
    );
  }
}
