class StockData {
  final String name;
  final String token;
  final double price;
  final double changePercent;

  StockData({
    required this.name,
    required this.token,
    required this.price,
    required this.changePercent,
  });

  bool get isPositive => changePercent >= 0;
}
