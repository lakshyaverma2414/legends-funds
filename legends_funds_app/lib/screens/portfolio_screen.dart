import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/stock_provider.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  void _showAddStockDialog(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final stockData = stockProvider.stockData;

    showDialog(
      context: context,
      builder: (context) => _AddStockDialog(stockData: stockData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer2<PortfolioProvider, StockProvider>(
        builder: (context, portfolioProvider, stockProvider, child) {
          final portfolio = portfolioProvider.portfolio;
          final stockData = stockProvider.stockData;

          if (portfolio.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text('No stocks in portfolio', style: TextStyle(fontSize: 18, color: Colors.grey[400])),
                  const SizedBox(height: 8),
                  Text('Tap + to add stocks', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          final totalValue = portfolioProvider.getTotalValue(stockData);
          final totalPL = portfolioProvider.getTotalProfitLoss(stockData);
          final totalPLPercent = totalValue > 0 ? (totalPL / (totalValue - totalPL)) * 100 : 0;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: const Color(0xFF1E1E1E),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Value', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('₹${totalValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(totalPL >= 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: totalPL >= 0 ? Colors.green[400] : Colors.red[400]),
                        const SizedBox(width: 4),
                        Text(
                          '₹${totalPL.abs().toStringAsFixed(2)} (${totalPL >= 0 ? '+' : ''}${totalPLPercent.toStringAsFixed(2)}%)',
                          style: TextStyle(color: totalPL >= 0 ? Colors.green[400] : Colors.red[400], fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: portfolio.length,
                  itemBuilder: (context, index) {
                    final item = portfolio[index];
                    final currentPrice = stockData[item.token]?['price'] ?? item.buyPrice;
                    final pl = item.getProfitLoss(currentPrice);
                    final plPercent = item.getProfitLossPercent(currentPrice);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.quantity} shares @ ₹${item.buyPrice.toStringAsFixed(2)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${pl >= 0 ? '+' : ''}₹${pl.toStringAsFixed(2)} (${plPercent.toStringAsFixed(1)}%)',
                              style: TextStyle(color: pl >= 0 ? Colors.green[400] : Colors.red[400], fontSize: 12),
                            ),
                          ],
                        ),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove Stock'),
                              content: Text('Remove ${item.name} from portfolio?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    portfolioProvider.removeStock(index);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStockDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddStockDialog extends StatefulWidget {
  final Map<String, dynamic> stockData;

  const _AddStockDialog({required this.stockData});

  @override
  State<_AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<_AddStockDialog> {
  String? selectedToken;
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final stocks = {
      '1333': 'HDFC BANK',
      '3045': 'SBI',
      '4963': 'ICICI BANK',
      '1922': 'KOTAK BANK',
      '5900': 'AXIS BANK',
    };

    return AlertDialog(
      title: const Text('Add Stock to Portfolio'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedToken,
              decoration: const InputDecoration(labelText: 'Select Stock'),
              items: stocks.entries.map((e) {
                final currentPrice = widget.stockData[e.key]?['price'] ?? 0.0;
                return DropdownMenuItem(
                  value: e.key,
                  child: Text('${e.value} (₹${currentPrice.toStringAsFixed(2)})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedToken = value;
                  if (value != null) {
                    priceController.text = (widget.stockData[value]?['price'] ?? 0.0).toStringAsFixed(2);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Buy Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedToken != null && quantityController.text.isNotEmpty && priceController.text.isNotEmpty) {
              final portfolioProvider = Provider.of<PortfolioProvider>(context, listen: false);
              portfolioProvider.addStock(
                selectedToken!,
                stocks[selectedToken]!,
                int.parse(quantityController.text),
                double.parse(priceController.text),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
