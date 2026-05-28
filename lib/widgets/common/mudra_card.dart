import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';

class MudraCard extends StatelessWidget {
  const MudraCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.elevation = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: elevation ? null : Border.all(color: AppColors.border),
        boxShadow: elevation
            ? const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
                BoxShadow(color: Color(0x06000000), blurRadius: 3, offset: Offset(0, 1)),
              ]
            : null,
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
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
