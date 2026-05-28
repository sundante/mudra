import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/onboarding_tour_provider.dart';
import '../common/mudra_button.dart';

class _TourStep {
  const _TourStep({required this.title, required this.body, required this.tab});
  final String title;
  final String body;
  final int tab;
}

const _steps = [
  _TourStep(
    title: 'Month at a glance',
    body:
        "This is Rohan's month — income, runway, and everything that's coming up.",
    tab: 0,
  ),
  _TourStep(
    title: 'No more surprises',
    body: 'Every EMI, SIP, and bill mapped out before it hits.',
    tab: 0,
  ),
  _TourStep(
    title: 'All your accounts',
    body: 'Savings, FDs, and credit cards in one clean view.',
    tab: 1,
  ),
  _TourStep(
    title: 'Your investments',
    body: 'SIPs and portfolio across every platform, live.',
    tab: 3,
  ),
  _TourStep(
    title: 'Your real number',
    body: 'Assets minus liabilities. This is your net worth.',
    tab: 4,
  ),
];

class GuidedTourOverlay extends ConsumerStatefulWidget {
  const GuidedTourOverlay({super.key});

  @override
  ConsumerState<GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

class _GuidedTourOverlayState extends ConsumerState<GuidedTourOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingTourProvider.notifier).startTour();
    });
  }

  void _navigateToStep(int step, BuildContext context) {
    final tab = _steps[step].tab;
    final paths = ['/', '/accounts', '/debts', '/portfolio', '/net'];
    context.go(paths[tab]);
  }

  @override
  Widget build(BuildContext context) {
    final tour = ref.watch(onboardingTourProvider);
    if (!tour.isVisible) return const SizedBox.shrink();

    final step = _steps[tour.currentStep];
    final isLast = tour.currentStep == _steps.length - 1;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: false,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xl + 80,
            ),
            child: _CalloutCard(
              step: tour.currentStep,
              total: _steps.length,
              title: step.title,
              body: step.body,
              isLast: isLast,
              onNext: () {
                final notifier = ref.read(onboardingTourProvider.notifier);
                if (isLast) {
                  notifier.endTour();
                  context.push('/onboarding/handoff');
                } else {
                  notifier.nextStep();
                  _navigateToStep(tour.currentStep + 1, context);
                }
              },
              onSkip: () {
                ref.read(onboardingTourProvider.notifier).endTour();
                context.push('/onboarding/handoff');
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CalloutCard extends StatelessWidget {
  const _CalloutCard({
    required this.step,
    required this.total,
    required this.title,
    required this.body,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  final int step;
  final int total;
  final String title;
  final String body;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '${step + 1} OF $total',
                style: AppTypography.sectionLabel
                    .copyWith(color: AppColors.gold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSkip,
                child: Text(
                  'SKIP TOUR',
                  style: AppTypography.sectionLabel
                      .copyWith(color: AppColors.inkDim),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTypography.headingSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style:
                AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
          ),
          const SizedBox(height: AppSpacing.md),
          MudraButton(
            label: isLast ? 'See the big picture →' : 'Next →',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
