import 'product.dart';

class TransactionItem {
  final Product product;
  int quantity;

  TransactionItem({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;
}

class Transaction {
  final String id;
  final DateTime date;
  final List<TransactionItem> items;
  final double total;
  final double discount;
  final double tax;
  final PaymentMethod paymentMethod;
  final double? cashReceived;
  final double? change;

  Transaction({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.discount,
    required this.tax,
    required this.paymentMethod,
    this.cashReceived,
    this.change,
  });

  double get grandTotal => total - discount + tax;
}

enum PaymentMethod {
  cash,
  digital,
}