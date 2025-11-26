import 'package:flutter/material.dart';
import 'package:layanan_sosial/menu/productpage.dart';
import 'package:layanan_sosial/menu/cashier.dart' as cashier;
import 'package:layanan_sosial/menu/ai.dart';

void main() {
  runApp(const SmartCashierApp());
}

class SmartCashierApp extends StatelessWidget {
  const SmartCashierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Cashier",
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D8CFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Smart Cashier\nRestorant Seafood",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Manajemen Produk
                menuCard(
                  imagePath: "assets/image/product.jpeg",
                  title: "Manajemen Product & Stock",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Productpage()),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Cashier Transactions
                menuCard(
                  imagePath: "assets/image/cashier.jpeg",
                  title: "Cashier Transactions",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const cashier.CartPage()),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // AI Feature
                menuCard(
                  imagePath: "assets/image/ai.jpeg",
                  title: "Feature AI",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FutureAi()),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget menuCard({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imagePath,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ─── HALAMAN MANAGEMEN PRODUK ─────────────────────────────────────────
//
class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Product & Stock")),
      body: const Center(child: Text("Halaman Manajemen Produk")),
    );
  }
}

//
// ─── HALAMAN CASHIER ─────────────────────────────────────────
//
class CashierPage extends StatelessWidget {
  const CashierPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cashier Transactions")),
      body: const Center(child: Text("Halaman Transaksi Kasir")),
    );
  }
}

//
// ─── HALAMAN FEATURE AI ─────────────────────────────────────────
//
class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Feature")),
      body: const Center(child: Text("Halaman Fitur AI")),
    );
  }
}