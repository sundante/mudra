import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Monthly spend data point for [SpendBarChart].
class SpendMonthData {
  const SpendMonthData({
    required this.month,
    required this.amount,
    required this.label,
  });

  final DateTime month;
  final double amount;

  /// Short month abbreviation, e.g. "Jan", "Feb".
  final String label;
}

/// Bar chart showing last 6 months of variable spend using fl_chart.
///
/// Example:
/// ```dart
/// SpendBarChart(
///   currency: '₹',
///   months: last6Months, // List<SpendMonthData> oldest first
/// )
/// ```
class SpendBarChart extends StatefulWidget {
  const SpendBarChart({
    super.key,
    required this.months,
    required this.currency,
  });

  /// Exactly 6 entries, oldest first.
  final List<SpendMonthData> months;
  final String currency;

  @override
  State<SpendBarChart> createState() => _SpendBarChartState();
}

class _SpendBarChartState extends State<SpendBarChart> {
  int _touchedIndex = -1;

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(widget.months.length, (i) {
      final isCurrentMonth = i == widget.months.length - 1;
      final isTouched = i == _touchedIndex;

      final Color baseColor = isCurrentMonth
          ? AppColors.gold
          : AppColors.gold.withValues(alpha: 0.2 + (i * 0.1));

      final Color rodColor = isTouched
          ? AppColors.goldLight
          : baseColor;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: widget.months[i].amount,
            width: 16,
            color: rodColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          barGroups: _buildBarGroups(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= widget.months.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.months[index].label,
                      style: AppTypography.monoXSmall.copyWith(
                        fontSize: 8,
                        color: AppColors.inkDim,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (response != null &&
                    response.spot != null &&
                    event is! FlTapUpEvent &&
                    event is! FlPanEndEvent) {
                  _touchedIndex = response.spot!.touchedBarGroupIndex;
                } else {
                  _touchedIndex = -1;
                }
              });
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final amount = widget.months[groupIndex].amount;
                return BarTooltipItem(
                  '${widget.currency}${_formatAmount(amount)}',
                  AppTypography.monoXSmall.copyWith(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
