import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/data_service.dart';

class Productpage extends StatefulWidget {
  const Productpage({super.key});

  @override
  State<Productpage> createState() => _ProductpageState();
}

class _ProductpageState extends State<Productpage> with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product & Stock Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Stock'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildStockTab(),
          _buildReportsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductsTab() {
    final products = _dataService.products;
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(product.name),
            subtitle: Text('${product.category} - Stock: ${product.stock}'),
            trailing: Text('Rp ${product.price}'),
            onTap: () => _showEditProductDialog(product),
          ),
        );
      },
    );
  }

  Widget _buildStockTab() {
    final products = _dataService.products;
    final lowStockProducts = _dataService.getLowStockProducts();

    return Column(
      children: [
        if (lowStockProducts.isNotEmpty) ...[
          Container(
            color: Colors.red[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 8),
                ...lowStockProducts.map((product) => Text(
                  '${product.name}: ${product.stock} remaining (threshold: ${product.lowStockThreshold})',
                  style: const TextStyle(color: Colors.red),
                )),
              ],
            ),
          ),
          const Divider(),
        ],
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text('Current Stock: ${product.stock}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _updateStock(product, product.stock - 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddStockDialog(product),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    final totalSales = _dataService.getTotalSales();
    final topProducts = _dataService.getTopSellingProducts();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Total Sales'),
                  Text(
                    'Rp ${totalSales.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Top Selling Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...topProducts.map((product) => Card(
            child: ListTile(
              title: Text(product.name),
              subtitle: Text(product.category),
              trailing: Text('Rp ${product.price}'),
            ),
          )),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final barcodeController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();
    final stockController = TextEditingController();
    final thresholdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: barcodeController, decoration: const InputDecoration(labelText: 'Barcode')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Initial Stock'), keyboardType: TextInputType.number),
              TextField(controller: thresholdController, decoration: const InputDecoration(labelText: 'Low Stock Threshold'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final product = Product(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                price: double.parse(priceController.text),
                barcode: barcodeController.text,
                category: categoryController.text,
                description: descriptionController.text,
                stock: int.parse(stockController.text),
                lowStockThreshold: int.parse(thresholdController.text),
              );
              _dataService.addProduct(product);
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final barcodeController = TextEditingController(text: product.barcode);
    final categoryController = TextEditingController(text: product.category);
    final descriptionController = TextEditingController(text: product.description);
    final thresholdController = TextEditingController(text: product.lowStockThreshold.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: barcodeController, decoration: const InputDecoration(labelText: 'Barcode')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: thresholdController, decoration: const InputDecoration(labelText: 'Low Stock Threshold'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final updatedProduct = product.copyWith(
                name: nameController.text,
                price: double.parse(priceController.text),
                barcode: barcodeController.text,
                category: categoryController.text,
                description: descriptionController.text,
                lowStockThreshold: int.parse(thresholdController.text),
              );
              _dataService.updateProduct(product.id, updatedProduct);
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog(Product product) {
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Stock for ${product.name}'),
        content: TextField(
          controller: stockController,
          decoration: const InputDecoration(labelText: 'Quantity to Add'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final quantity = int.parse(stockController.text);
              _updateStock(product, product.stock + quantity);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _updateStock(Product product, int newStock) {
    if (newStock >= 0) {
      final updatedProduct = product.copyWith(stock: newStock);
      _dataService.updateProduct(product.id, updatedProduct);
      setState(() {});
    }
  }
}