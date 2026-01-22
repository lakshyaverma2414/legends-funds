import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/stock_data.dart';

class StockCard extends StatelessWidget {
  final StockData stock;
  final List<dynamic> history;

  const StockCard({super.key, required this.stock, this.history = const []});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '₹${stock.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  stock.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: stock.isPositive ? Colors.green[400] : Colors.red[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '${stock.changePercent > 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: stock.isPositive ? Colors.green[400] : Colors.red[400],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: history.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[800]!, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          'Loading...',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                    )
                  : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (history.length < 2) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Collecting data...',
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      final price = history[i]['price']?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), price));
    }

    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: minY - padding,
        maxY: maxY + padding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: stock.isPositive ? Colors.green[400] : Colors.red[400],
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: (stock.isPositive ? Colors.green[400] : Colors.red[400])?.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
