import '../models/product.dart';
import '../models/transaction.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Roti',
      price: 5000,
      barcode: '123456789',
      category: 'Bakery',
      description: 'Roti tawar segar',
      stock: 50,
      lowStockThreshold: 10,
    ),
    Product(
      id: '2',
      name: 'Selai Cokelat',
      price: 15000,
      barcode: '987654321',
      category: 'Spread',
      description: 'Selai cokelat premium',
      stock: 20,
      lowStockThreshold: 5,
    ),
    Product(
      id: '3',
      name: 'Mentega',
      price: 12000,
      barcode: '456789123',
      category: 'Dairy',
      description: 'Mentega murni',
      stock: 15,
      lowStockThreshold: 3,
    ),
    Product(
      id: '4',
      name: 'Kopi Kecil',
      price: 8000,
      barcode: '789123456',
      category: 'Beverage',
      description: 'Kopi hitam kecil',
      stock: 30,
      lowStockThreshold: 5,
    ),
    Product(
      id: '5',
      name: 'Kopi Besar',
      price: 12000,
      barcode: '321654987',
      category: 'Beverage',
      description: 'Kopi hitam besar',
      stock: 25,
      lowStockThreshold: 5,
    ),
  ];

  final List<Transaction> _transactions = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  void addProduct(Product product) {
    _products.add(product);
  }

  void updateProduct(String id, Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = updatedProduct;
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
  }

  Product? getProductByBarcode(String barcode) {
    return _products.firstWhere((p) => p.barcode == barcode);
  }

  List<Product> searchProducts(String query) {
    return _products.where((p) =>
      p.name.toLowerCase().contains(query.toLowerCase()) ||
      p.barcode.contains(query)
    ).toList();
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    // Update stock
    for (var item in transaction.items) {
      final product = _products.firstWhere((p) => p.id == item.product.id);
      product.stock -= item.quantity;
    }
  }

  List<Product> getLowStockProducts() {
    return _products.where((p) => p.isLowStock).toList();
  }

  List<Product> getTopSellingProducts() {
    // Simple implementation - count sales from transactions
    final salesCount = <String, int>{};
    for (var transaction in _transactions) {
      for (var item in transaction.items) {
        salesCount[item.product.id] = (salesCount[item.product.id] ?? 0) + item.quantity;
      }
    }
    final sorted = salesCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => _products.firstWhere((p) => p.id == e.key)).toList();
  }

  double getTotalSales() {
    return _transactions.fold(0, (sum, t) => sum + t.grandTotal);
  }
}