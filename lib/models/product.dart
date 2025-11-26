class Product {
  final String id;
  final String name;
  final double price;
  final String barcode;
  final String category;
  final String description;
  int stock;
  final int lowStockThreshold;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.barcode,
    required this.category,
    required this.description,
    required this.stock,
    required this.lowStockThreshold,
  });

  bool get isLowStock => stock <= lowStockThreshold;

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? barcode,
    String? category,
    String? description,
    int? stock,
    int? lowStockThreshold,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }
}