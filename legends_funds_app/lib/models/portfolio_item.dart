class PortfolioItem {
  final String token;
  final String name;
  final int quantity;
  final double buyPrice;

  PortfolioItem({
    required this.token,
    required this.name,
    required this.quantity,
    required this.buyPrice,
  });

  double getCurrentValue(double currentPrice) {
    return quantity * currentPrice;
  }

  double getProfitLoss(double currentPrice) {
    return (currentPrice - buyPrice) * quantity;
  }

  double getProfitLossPercent(double currentPrice) {
    return ((currentPrice - buyPrice) / buyPrice) * 100;
  }
}
