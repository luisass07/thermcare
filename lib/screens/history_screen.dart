import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<double> temps = const [36.5, 36.8, 37.1, 37.8, 38.2, 38.0, 37.5, 37.0, 36.7, 36.5];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Historial de temperatura',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2D45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.white12, strokeWidth: 1),
                  getDrawingVerticalLine: (_) =>
                      FlLine(color: Colors.white12, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}h',
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toStringAsFixed(1)}°',
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 35.0,
                maxY: 40.0,
                lineBarsData: [
                  LineChartBarData(
                    spots: temps
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFF0A7AFF),
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF0A7AFF).withValues(alpha: 0.15),
                    ),
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: List.generate(10, (i) => FlSpot(i.toDouble(), 38.0)),
                    color: Colors.redAccent.withValues(alpha: 0.5),
                    barWidth: 1,
                    dashArray: [6, 4],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Registros recientes',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...temps.asMap().entries.map((e) => _historyTile(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _historyTile(int index, double temp) {
    final isHigh = temp >= 38.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2D45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHigh ? Colors.redAccent.withValues(alpha: 0.5) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${index + 1}:00 PM', style: const TextStyle(color: Colors.grey)),
          Text(
            '${temp.toStringAsFixed(1)} °C',
            style: TextStyle(
              color: isHigh ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isHigh
                  ? Colors.redAccent.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isHigh ? 'Fiebre' : 'Normal',
              style: TextStyle(
                color: isHigh ? Colors.redAccent : Colors.green,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
