import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock_data.dart';
import '../widgets/stock_card.dart';
import '../providers/stock_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning! 🌞';
    } else if (hour < 17) {
      return 'Good Afternoon! ☀️';
    } else if (hour < 21) {
      return 'Good Evening! 🌆';
    } else {
      return 'Good Night! 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text('Legends Funds', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.account_circle_outlined), onPressed: () {}),
        ],
      ),
      body: Consumer<StockProvider>(
        builder: (context, stockProvider, child) {
          if (stockProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stockData = stockProvider.stockData;
          final stocks = [
            StockData(
              name: 'HDFC BANK',
              token: '1333',
              price: stockData['1333']?['price'] ?? 0.0,
              changePercent: stockData['1333']?['change'] ?? 0.0,
            ),
            StockData(
              name: 'SBI',
              token: '3045',
              price: stockData['3045']?['price'] ?? 0.0,
              changePercent: stockData['3045']?['change'] ?? 0.0,
            ),
            StockData(
              name: 'ICICI BANK',
              token: '4963',
              price: stockData['4963']?['price'] ?? 0.0,
              changePercent: stockData['4963']?['change'] ?? 0.0,
            ),
            StockData(
              name: 'KOTAK BANK',
              token: '1922',
              price: stockData['1922']?['price'] ?? 0.0,
              changePercent: stockData['1922']?['change'] ?? 0.0,
            ),
            StockData(
              name: 'AXIS BANK',
              token: '5900',
              price: stockData['5900']?['price'] ?? 0.0,
              changePercent: stockData['5900']?['change'] ?? 0.0,
            ),
          ];

          return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome to Legends Funds',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: stocks.length,
                itemBuilder: (context, index) => StockCard(
                  stock: stocks[index],
                  history: stockData[stocks[index].token]?['history'] ?? [],
                ),
              ),
            ),
          ],
        ),
          );
        },
      ),
    );
  }
}
