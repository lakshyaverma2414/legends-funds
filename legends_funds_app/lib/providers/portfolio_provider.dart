import 'package:flutter/material.dart';
import '../models/portfolio_item.dart';

class PortfolioProvider extends ChangeNotifier {
  final List<PortfolioItem> _portfolio = [];

  List<PortfolioItem> get portfolio => _portfolio;

  void addStock(String token, String name, int quantity, double buyPrice) {
    _portfolio.add(PortfolioItem(
      token: token,
      name: name,
      quantity: quantity,
      buyPrice: buyPrice,
    ));
    notifyListeners();
  }

  void removeStock(int index) {
    _portfolio.removeAt(index);
    notifyListeners();
  }

  double getTotalValue(Map<String, dynamic> stockData) {
    double total = 0;
    for (var item in _portfolio) {
      final currentPrice = stockData[item.token]?['price'] ?? item.buyPrice;
      total += item.getCurrentValue(currentPrice);
    }
    return total;
  }

  double getTotalProfitLoss(Map<String, dynamic> stockData) {
    double total = 0;
    for (var item in _portfolio) {
      final currentPrice = stockData[item.token]?['price'] ?? item.buyPrice;
      total += item.getProfitLoss(currentPrice);
    }
    return total;
  }
}
