import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';

/// A single data point for [SparklineChart].
class SparklinePoint {
  const SparklinePoint({required this.day, required this.amount});

  final int day;

  /// Cumulative spend up to this day.
  final double amount;
}

/// Daily spend sparkline for the current month. Area fill + line, no axes.
/// Purely visual — no touch interaction.
///
/// Example:
/// ```dart
/// SparklineChart(
///   points: dailyPoints,
///   lineColor: AppColors.gold,
/// )
/// ```
class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.points,
    this.lineColor,
  });

  final List<SparklinePoint> points;

  /// Defaults to [AppColors.gold] when null.
  final Color? lineColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = lineColor ?? AppColors.gold;

    final spots = points
        .map((p) => FlSpot(p.day.toDouble(), p.amount))
        .toList();

    return SizedBox(
      height: 60,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: effectiveColor,
              barWidth: 2.0,
              isCurved: true,
              curveSmoothness: 0.3,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) =>
                    spot == barData.spots.last,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    effectiveColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
