import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFF2D8CFF), // biru background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title
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

                // =========================
                // Card 1 – Manajemen Produk & Stock
                // =========================
                menuCard(
                  imageUrl:
                      "https://i.ibb.co/7CqVJ6X/seafood.png",
                  title: "Manajemen Product & Stock",
                  onTap: () {},
                ),

                const SizedBox(height: 40),

                // =========================
                // Card 2 – Kasir / Transaksi
                // =========================
                menuCard(
                  imageUrl:
                      "https://i.ibb.co/THgJtTC/cashier.png",
                  title: "Cashier Transactions",
                  onTap: () {},
                ),

                const SizedBox(height: 40),

                // =========================
                // Card 3 – AI Feature
                // =========================
                menuCard(
                  imageUrl:
                      "https://i.ibb.co/6B4rtVx/ai.png",
                  title: "Feature AI",
                  onTap: () {},
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // Widget Card Menu
  // =========================
  Widget menuCard({
    required String imageUrl,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),

            // Text
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
