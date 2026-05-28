import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum TimelineRange { oneMonth, threeMonths, sixMonths, oneYear, all }

extension TimelineRangeX on TimelineRange {
  String get label => switch (this) {
        TimelineRange.oneMonth => '1M',
        TimelineRange.threeMonths => '3M',
        TimelineRange.sixMonths => '6M',
        TimelineRange.oneYear => '1Y',
        TimelineRange.all => 'All',
      };

  DateTime? get cutoff {
    final now = DateTime.now();
    return switch (this) {
      TimelineRange.oneMonth => DateTime(now.year, now.month - 1, now.day),
      TimelineRange.threeMonths => DateTime(now.year, now.month - 3, now.day),
      TimelineRange.sixMonths => DateTime(now.year, now.month - 6, now.day),
      TimelineRange.oneYear => DateTime(now.year - 1, now.month, now.day),
      TimelineRange.all => null,
    };
  }
}

class TimelineFilterBar extends StatelessWidget {
  const TimelineFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.padding,
  });

  final TimelineRange selected;
  final ValueChanged<TimelineRange> onChanged;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenH,
            vertical: AppSpacing.sm,
          ),
      child: Row(
        children: TimelineRange.values.map((r) {
          final active = r == selected;
          return GestureDetector(
            onTap: () => onChanged(r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: active ? AppColors.gold : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: active ? AppColors.gold : AppColors.border,
                ),
              ),
              child: Text(
                r.label,
                style: AppTypography.labelSmall.copyWith(
                  color: active ? Colors.white : AppColors.inkDim,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
