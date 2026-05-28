import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/account.dart';
import '../../providers/setup_wizard_provider.dart';
import '../../widgets/common/mudra_button.dart';
import '../../widgets/common/mudra_input.dart';

class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  final _pageController = PageController();

  // Step 1
  final _incomeController = TextEditingController();

  // Step 2
  final _accountNameController = TextEditingController();
  final _accountBalanceController = TextEditingController();
  AccountType _accountType = AccountType.personal;

  // Step 3
  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  final _expenseDayController = TextEditingController();

  int _currentPage = 0;
  bool _isBusy = false;

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    _accountNameController.dispose();
    _accountBalanceController.dispose();
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    _expenseDayController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    }
  }

  Future<void> _finish() async {
    setState(() => _isBusy = true);
    await ref.read(setupWizardProvider.notifier).complete(
          monthlyIncome: double.tryParse(_incomeController.text),
          accountNickname: _accountNameController.text.trim(),
          accountType: _accountType,
          accountBalance: double.tryParse(_accountBalanceController.text),
          expenseName: _expenseNameController.text.trim(),
          expenseAmount: double.tryParse(_expenseAmountController.text),
          expenseDayOfMonth: int.tryParse(_expenseDayController.text),
        );
    if (mounted) setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _StepIndicator(current: _currentPage, total: 3),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepPage(
                    stepLabel: 'STEP 1 OF 3',
                    title: "What's your monthly\ntake-home?",
                    subtitle:
                        'This helps Mudra show your runway and spending headroom.',
                    isBusy: _isBusy,
                    onSkip: _next,
                    onContinue: _next,
                    child: MudraInput(
                      controller: _incomeController,
                      label: 'Monthly income',
                      hintText: '1,20,000',
                      keyboardType: TextInputType.number,
                      amountMode: true,
                    ),
                  ),
                  _StepPage(
                    stepLabel: 'STEP 2 OF 3',
                    title: 'Add your first account',
                    subtitle:
                        'Savings account, credit card — anything you want to track.',
                    isBusy: _isBusy,
                    onSkip: _next,
                    onContinue: _next,
                    child: Column(
                      children: [
                        MudraInput(
                          controller: _accountNameController,
                          label: 'Account name',
                          hintText: 'HDFC Savings',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        MudraInput(
                          controller: _accountBalanceController,
                          label: 'Current balance',
                          hintText: '85,000',
                          keyboardType: TextInputType.number,
                          amountMode: true,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _AccountTypeSelector(
                          value: _accountType,
                          onChanged: (t) => setState(() => _accountType = t),
                        ),
                      ],
                    ),
                  ),
                  _StepPage(
                    stepLabel: 'STEP 3 OF 3',
                    title: 'Any recurring\nexpenses?',
                    subtitle: 'An EMI, subscription, or rent — add one to start.',
                    isBusy: _isBusy,
                    onSkip: _finish,
                    onContinue: _finish,
                    continueLabel: "Let's go",
                    child: Column(
                      children: [
                        MudraInput(
                          controller: _expenseNameController,
                          label: 'Expense name',
                          hintText: 'Home Loan EMI',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        MudraInput(
                          controller: _expenseAmountController,
                          label: 'Amount',
                          hintText: '18,500',
                          keyboardType: TextInputType.number,
                          amountMode: true,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        MudraInput(
                          controller: _expenseDayController,
                          label: 'Day of month',
                          hintText: '5',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= current;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
              height: 3,
              decoration: BoxDecoration(
                color: active ? AppColors.gold : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage({
    required this.stepLabel,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.isBusy,
    required this.onSkip,
    required this.onContinue,
    this.continueLabel = 'Continue',
  });

  final String stepLabel;
  final String title;
  final String subtitle;
  final Widget child;
  final bool isBusy;
  final VoidCallback onSkip;
  final VoidCallback onContinue;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stepLabel, style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.headingLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
          const SizedBox(height: AppSpacing.xl),
          MudraButton(
            label: continueLabel,
            onPressed: isBusy ? null : onContinue,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: isBusy ? null : onSkip,
              child: Text(
                'Skip for now',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.inkDim),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTypeSelector extends StatelessWidget {
  const _AccountTypeSelector({required this.value, required this.onChanged});
  final AccountType value;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    const types = [
      (AccountType.personal, 'Personal'),
      (AccountType.joint, 'Joint'),
      (AccountType.business, 'Business'),
    ];
    return Row(
      children: types.map((entry) {
        final (type, label) = entry;
        final selected = value == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.gold : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: selected ? Colors.white : AppColors.ink,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
