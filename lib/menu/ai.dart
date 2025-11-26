import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../services/data_service.dart';

class FutureAi extends StatefulWidget {
  const FutureAi({super.key});

  @override
  State<FutureAi> createState() => _FutureAiState();
}

class _FutureAiState extends State<FutureAi> {
  final DataService _dataService = DataService();
  final List<TransactionItem> _currentCart = [];
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  List<Product> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _updateRecommendations();
  }

  void _updateRecommendations() {
    _recommendations = _getRecommendations();
    setState(() {});
  }

  List<Product> _getRecommendations() {
    final recommendations = <Product>[];

    // Primary: Top-selling products based on transaction history
    final topSellingProducts = _dataService.getTopSellingProducts();
    recommendations.addAll(topSellingProducts);

    // Secondary: Cross-selling based on current cart items (if cart has items)
    if (_currentCart.isNotEmpty) {
      final cartCategories = _currentCart.map((item) => item.product.category).toSet();
      final cartProducts = _currentCart.map((item) => item.product).toList();

      for (final category in cartCategories) {
        final categoryProducts = _dataService.products
            .where((p) => p.category == category && !cartProducts.contains(p) && !topSellingProducts.contains(p))
            .toList();
        recommendations.addAll(categoryProducts.take(1)); // Take 1 per category to supplement top sellers
      }
    }

    // Remove duplicates and limit to 5
    final uniqueRecommendations = recommendations.toSet().toList();
    return uniqueRecommendations.take(5).toList();
  }

  void _addToCart(Product product) {
    final existingItem = _currentCart.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => TransactionItem(product: product, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      _currentCart.add(TransactionItem(product: product, quantity: 1));
    } else {
      existingItem.quantity++;
    }
    _updateRecommendations();
  }

  void _smartSearch(String query) {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      // Simple fuzzy search - in real app, use more sophisticated algorithm
      _searchResults = _dataService.products.where((product) {
        final name = product.name.toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) ||
               _levenshteinDistance(name, searchQuery) <= 2; // Allow 2 character differences
      }).toList();
    }
    setState(() {});
  }

  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix = List.generate(s1.length + 1, (i) => List.filled(s2.length + 1, 0));

    for (int i = 0; i <= s1.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= s2.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  double _calculateSuggestedDiscount() {
    // Simple discount suggestion based on cart value and items
    final cartValue = _currentCart.fold(0.0, (sum, item) => sum + item.subtotal);
    final itemCount = _currentCart.fold(0, (sum, item) => sum + item.quantity);

    if (cartValue > 50000 && itemCount >= 3) {
      return cartValue * 0.1; // 10% discount for large orders
    } else if (itemCount >= 2) {
      return cartValue * 0.05; // 5% discount for multiple items
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Features & Recommendations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Search
            const Text(
              'Smart Product Search',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _smartSearch,
            ),
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Search Results:'),
              ..._searchResults.map((product) => Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text('${product.category} - Rp ${product.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _addToCart(product),
                  ),
                ),
              )),
            ],

            const SizedBox(height: 32),

            // Current Cart
            if (_currentCart.isNotEmpty) ...[
              const Text(
                'Current Cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._currentCart.map((item) => Card(
                child: ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Text('Rp ${item.subtotal}'),
                ),
              )),
              const SizedBox(height: 16),
              if (_calculateSuggestedDiscount() > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[100],
                  child: Text(
                    'Suggested Discount: Rp ${_calculateSuggestedDiscount().toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],

            // Recommendations
            if (_recommendations.isNotEmpty) ...[
              const Text(
                'Recommended Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Frequently purchased by customers',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ..._recommendations.map((product) => Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text('${product.category} - Rp ${product.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _addToCart(product),
                  ),
                ),
              )),
            ],

            const SizedBox(height: 32),

            // AI Insights
            const Text(
              'AI Insights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Product Recommendations',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'AI analyzes transaction history to recommend products that customers frequently purchase.',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cross-Selling Analysis',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When items are in cart, complementary products from the same category are suggested.',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Smart Search',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fuzzy matching allows finding products even with typos or partial names.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}