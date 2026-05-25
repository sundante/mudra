import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class FundsScreen extends StatelessWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mudra',
            style: AppTypography.headingMedium.copyWith(color: AppColors.gold)),
      ),
      body: Center(
        child: Text('Funds — coming soon',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim)),
      ),
    );
  }
}
