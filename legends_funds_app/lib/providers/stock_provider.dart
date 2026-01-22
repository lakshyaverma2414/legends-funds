import 'package:flutter/material.dart';
import '../services/stock_service.dart';

class StockProvider extends ChangeNotifier {
  final StockService _stockService = StockService();
  Map<String, dynamic> _stockData = {};
  bool _isLoading = true;

  Map<String, dynamic> get stockData => _stockData;
  bool get isLoading => _isLoading;

  StockProvider() {
    _initializeService();
  }

  void _initializeService() {
    _stockService.onDataUpdate = (data) {
      _stockData = data;
      _isLoading = false;
      notifyListeners();
    };
    _stockService.startPolling();
  }

  @override
  void dispose() {
    _stockService.stopPolling();
    super.dispose();
  }
}
