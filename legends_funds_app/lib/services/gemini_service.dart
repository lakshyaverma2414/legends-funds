import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyC0MJP5-QtD2yQ9fQX8hjyG1oZdOeHb0Pg';
  late final GenerativeModel model;

  GeminiService() {
    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> sendMessage(String message, {Map<String, dynamic>? stockContext, List<dynamic>? portfolio}) async {
    try {
      String contextPrompt = message;
      
      if (stockContext != null && stockContext.isNotEmpty) {
        String stockInfo = '\n\nCurrent Stock Prices:\n';
        stockContext.forEach((token, data) {
          stockInfo += '${data['name']}: ₹${data['price'].toStringAsFixed(2)} (${data['change'] > 0 ? '+' : ''}${data['change'].toStringAsFixed(2)}%)\n';
        });
        
        String portfolioInfo = '';
        if (portfolio != null && portfolio.isNotEmpty) {
          portfolioInfo = '\n\nUser Portfolio:\n';
          for (var item in portfolio) {
            final currentPrice = stockContext[item['token']]?['price'] ?? item['buyPrice'];
            final pl = (currentPrice - item['buyPrice']) * item['quantity'];
            final plPercent = ((currentPrice - item['buyPrice']) / item['buyPrice']) * 100;
            portfolioInfo += '${item['name']}: ${item['quantity']} shares @ ₹${item['buyPrice'].toStringAsFixed(2)} | Current: ₹${currentPrice.toStringAsFixed(2)} | P/L: ${pl >= 0 ? '+' : ''}₹${pl.toStringAsFixed(2)} (${plPercent.toStringAsFixed(2)}%)\n';
          }
        }
        
        contextPrompt = 'You are a helpful investment assistant for Indian stock market. Here is the current market data:$stockInfo$portfolioInfo\n\nUser question: $message\n\nProvide helpful, concise investment advice.';
      }

      final content = [Content.text(contextPrompt)];
      final response = await model.generateContent(content);
      
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
