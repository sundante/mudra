import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';

class DonutSegment {
  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class AssetAllocationDonut extends StatefulWidget {
  const AssetAllocationDonut({
    super.key,
    required this.segments,
    required this.currency,
    this.size = 140,
  });

  final List<DonutSegment> segments;
  final String currency;
  final double size;

  @override
  State<AssetAllocationDonut> createState() => _AssetAllocationDonutState();
}

class _AssetAllocationDonutState extends State<AssetAllocationDonut> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final nonZero =
        widget.segments.where((s) => s.value > 0).toList();
    if (nonZero.isEmpty) return const SizedBox.shrink();

    final total = nonZero.fold(0.0, (s, e) => s + e.value);

    final sections = nonZero.asMap().entries.map((entry) {
      final i = entry.key;
      final seg = entry.value;
      final touched = i == _touchedIndex;
      return PieChartSectionData(
        value: seg.value,
        color: seg.color,
        radius: touched ? 30 : 22,
        title: '',
        badgeWidget: null,
      );
    }).toList();

    return Row(
      children: [
        SizedBox(
          height: widget.size,
          width: widget.size,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: widget.size / 2 - 30,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                    } else {
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: nonZero.asMap().entries.map((entry) {
              final i = entry.key;
              final seg = entry.value;
              final pct = total > 0 ? seg.value / total * 100 : 0.0;
              final active = i == _touchedIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: seg.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        seg.label,
                        style: AppTypography.monoXSmall.copyWith(
                          color: active ? AppColors.ink : AppColors.inkDim,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      active
                          ? CurrencyFormatter.format(seg.value, widget.currency)
                          : '${pct.toStringAsFixed(0)}%',
                      style: AppTypography.monoXSmall.copyWith(
                        color: active ? seg.color : AppColors.inkDim,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
