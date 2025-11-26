import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../services/data_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final DataService _dataService = DataService();
  final List<TransactionItem> _cartItems = [];

  @override
  Widget build(BuildContext context) {
    int totalItem = _cartItems.fold(0, (sum, item) => sum + item.quantity);
    double totalPrice = _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2D8CFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Text(
                    "Cashier",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),

          // ================= PRODUCTS LIST =================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  "Available Products",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._dataService.products.map((product) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text('${product.category} - Stock: ${product.stock}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rp ${product.price.toStringAsFixed(0)}'),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _addToCart(product),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
                )),

                const Divider(height: 40),

                const Text(
                  "Cart Items",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // ================= CART ITEMS =================
                ..._cartItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${item.product.name} x${item.quantity}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        "Rp ${item.subtotal.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _removeFromCart(item.product),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          // ================= SUMMARY BOX =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Colors.grey,
            ),
            child: const SizedBox(height: 1),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Items",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "$totalItem",
                      style:
                          const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Price",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Rp ${totalPrice.toStringAsFixed(0)}",
                      style:
                          const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= CHECKOUT BUTTON =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2D8CFF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: _cartItems.isEmpty ? null : _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D8CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Checkout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _addToCart(Product product) {
    setState(() {
      final existingItem = _cartItems.firstWhere(
        (item) => item.product.id == product.id,
        orElse: () => TransactionItem(product: product, quantity: 0),
      );

      if (_cartItems.contains(existingItem)) {
        existingItem.quantity++;
      } else {
        _cartItems.add(TransactionItem(product: product, quantity: 1));
      }
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      final existingItem = _cartItems.firstWhere(
        (item) => item.product.id == product.id,
      );

      if (existingItem.quantity > 1) {
        existingItem.quantity--;
      } else {
        _cartItems.remove(existingItem);
      }
    });
  }

  void _checkout() {
    final total = _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: List.from(_cartItems),
      total: total,
      discount: 0,
      tax: 0,
      paymentMethod: PaymentMethod.cash,
    );

    _dataService.addTransaction(transaction);

    setState(() {
      _cartItems.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction completed successfully!')),
    );
  }
}
