import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../services/data_service.dart';

class Cashier extends StatefulWidget {
  const Cashier({super.key});

  @override
  State<Cashier> createState() => _CashierState();
}

class _CashierState extends State<Cashier> {
  final DataService _dataService = DataService();
  final List<TransactionItem> _cart = [];
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  double _discount = 0.0;
  double _taxRate = 0.1; // 10% tax

  double get _subtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  double get _tax => _subtotal * _taxRate;
  double get _total => _subtotal - _discount + _tax;

  void _addProductToCart(Product product) {
    final existingItem = _cart.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => TransactionItem(product: product, quantity: 0),
    );

    if (existingItem.quantity == 0) {
      _cart.add(TransactionItem(product: product, quantity: 1));
    } else {
      existingItem.quantity++;
    }
    setState(() {});
  }

  void _removeFromCart(int index) {
    _cart.removeAt(index);
    setState(() {});
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeFromCart(index);
    } else {
      _cart[index].quantity = quantity;
      setState(() {});
    }
  }

  void _scanProduct() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isNotEmpty) {
      final product = _dataService.getProductByBarcode(barcode);
      if (product != null) {
        _addProductToCart(product);
        _barcodeController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
      }
    }
  }

  void _searchAndAddProduct() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final products = _dataService.searchProducts(query);
      if (products.isNotEmpty) {
        _showProductSelectionDialog(products);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No products found')),
        );
      }
    }
  }

  void _showProductSelectionDialog(List<Product> products) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Product'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('Rp ${product.price}'),
                onTap: () {
                  _addProductToCart(product);
                  _searchController.clear();
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _completeTransaction(PaymentMethod paymentMethod, {double? cashReceived}) {
    if (_cart.isEmpty) return;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: List.from(_cart),
      total: _subtotal,
      discount: _discount,
      tax: _tax,
      paymentMethod: paymentMethod,
      cashReceived: cashReceived,
      change: cashReceived != null ? cashReceived - _total : null,
    );

    _dataService.addTransaction(transaction);
    _cart.clear();
    _discount = 0.0;
    setState(() {});

    _showReceiptDialog(transaction);
  }

  void _showReceiptDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Transaction ID: ${transaction.id}'),
              Text('Date: ${transaction.date}'),
              const Divider(),
              ...transaction.items.map((item) =>
                Text('${item.product.name} x${item.quantity} - Rp ${item.subtotal}')
              ),
              const Divider(),
              Text('Subtotal: Rp ${_subtotal.toStringAsFixed(0)}'),
              Text('Discount: Rp ${_discount.toStringAsFixed(0)}'),
              Text('Tax: Rp ${_tax.toStringAsFixed(0)}'),
              Text('Total: Rp ${transaction.grandTotal.toStringAsFixed(0)}'),
              if (transaction.cashReceived != null) ...[
                Text('Cash Received: Rp ${transaction.cashReceived}'),
                Text('Change: Rp ${transaction.change}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    final cashController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _completeTransaction(PaymentMethod.digital),
              child: const Text('Digital Payment'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cash Received'),
            ),
            ElevatedButton(
              onPressed: () {
                final cash = double.tryParse(cashController.text);
                if (cash != null && cash >= _total) {
                  _completeTransaction(PaymentMethod.cash, cashReceived: cash);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid cash amount')),
                  );
                }
              },
              child: const Text('Pay with Cash'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier Transactions'),
        actions: [
          if (_cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: _showPaymentDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // Product Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: 'Barcode',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanProduct,
                    ),
                  ),
                  onSubmitted: (_) => _scanProduct(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Product',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchAndAddProduct,
                    ),
                  ),
                  onSubmitted: (_) => _searchAndAddProduct(),
                ),
              ],
            ),
          ),

          // Cart
          Expanded(
            child: ListView.builder(
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final item = _cart[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Rp ${item.product.price}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _updateQuantity(index, item.quantity - 1),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _updateQuantity(index, item.quantity + 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeFromCart(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text('Rp ${_subtotal.toStringAsFixed(0)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discount:'),
                    Text('Rp ${_discount.toStringAsFixed(0)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax:'),
                    Text('Rp ${_tax.toStringAsFixed(0)}'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rp ${_total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}