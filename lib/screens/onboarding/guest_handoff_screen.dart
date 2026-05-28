import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/mudra_button.dart';

class GuestHandoffScreen extends ConsumerWidget {
  const GuestHandoffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1C04), Color(0xFFA07020)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                // Animation stub — wrap in AnimatedOpacity / SlideTransition later
                Opacity(
                  opacity: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your finances.\nYour story.',
                        style: AppTypography.displayLarge.copyWith(
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        "You've seen what's possible.\nNow make it yours.",
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Animation stub for buttons
                Opacity(
                  opacity: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MudraButton(
                        label: 'Create free account',
                        onPressed: () {
                          ref
                              .read(appSessionControllerProvider)
                              .exitGuestMode();
                          context.go('/auth/register');
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      MudraButton(
                        label: 'Log in',
                        variant: MudraButtonVariant.secondary,
                        onPressed: () {
                          ref
                              .read(appSessionControllerProvider)
                              .exitGuestMode();
                          context.go('/auth/login');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
