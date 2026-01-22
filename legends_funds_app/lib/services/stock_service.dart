import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  static const String baseUrl = 'http://localhost:5000';
  Timer? _timer;
  Function(Map<String, dynamic>)? onDataUpdate;

  void startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final data = await fetchStocks();
        if (onDataUpdate != null) {
          onDataUpdate!(data);
        }
      } catch (e) {
        print('Error fetching stocks: $e');
      }
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<Map<String, dynamic>> fetchStocks() async {
    final response = await http.get(Uri.parse('$baseUrl/api/stocks'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stocks');
    }
  }
}
