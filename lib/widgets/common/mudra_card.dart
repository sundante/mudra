import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';

/// Standard card. White bg, grey border, 12px padding.
///
/// `.primary` — white bg, 3px gold left border, for the most important card per screen.
/// `.stat`    — same as default, used for side-by-side stat grid cells.
class MudraCard extends StatelessWidget {
  const MudraCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  })  : _isPrimary = false;

  const MudraCard.primary({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  })  : _isPrimary = true;

  const MudraCard.stat({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  })  : _isPrimary = false;

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool _isPrimary;

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppSpacing.cardPad);

    final content = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(
          left: BorderSide(
            color: _isPrimary ? AppColors.gold : AppColors.border,
            width: _isPrimary ? 3 : 1,
          ),
          top: const BorderSide(color: AppColors.border),
          right: const BorderSide(color: AppColors.border),
          bottom: const BorderSide(color: AppColors.border),
        ),
      ),
      padding: effectivePadding,
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: content,
      ),
    );
  }
}
