import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/database.dart';
import '../../data/models/app_settings.dart';
import '../../data/seed_data.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/mudra_button.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/mudra_input.dart';
import '../../widgets/common/section_label.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.inkDim),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load profile')),
        data: (settings) => _ProfileBody(settings: settings),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = _initials(settings.safeUserName);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.screenV,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      children: [
        // ── Avatar + Name ──────────────────────────────────────────────
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _openNameSheet(context, ref, settings),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    initials.isEmpty ? 'M' : initials,
                    style: AppTypography.displaySmall.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => _openNameSheet(context, ref, settings),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      settings.safeUserName.isEmpty
                          ? 'Add your name'
                          : settings.safeUserName,
                      style: AppTypography.bodyLarge.copyWith(
                        color: settings.safeUserName.isEmpty
                            ? AppColors.inkDim
                            : AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.edit_outlined,
                        size: 16, color: AppColors.inkDim),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Finance Anchors ───────────────────────────────────────────
        const SectionLabel('income & schedule'),
        const SizedBox(height: AppSpacing.sm),
        MudraCard(
          onTap: () => _openIncomeSheet(context, ref, settings),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Income',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.ink)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      CurrencyFormatter.format(
                          settings.safeMonthlyIncome,
                          settings.safeBaseCurrency),
                      style: AppTypography.monoMedium
                          .copyWith(color: AppColors.green),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkDim),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        MudraCard(
          onTap: () => _openPayDateSheet(context, ref, settings),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pay Date',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.ink)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Day ${settings.safePayDate} of every month',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.inkDim),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkDim),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Currency ──────────────────────────────────────────────────
        const SectionLabel('currency'),
        const SizedBox(height: AppSpacing.sm),
        _CurrencyChips(
          selected: settings.safeBaseCurrency,
          onSelect: (currency) => _saveCurrency(ref, settings, currency),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Danger Zone ───────────────────────────────────────────────
        const SectionLabel('data'),
        const SizedBox(height: AppSpacing.sm),
        MudraCard(
          onTap: () => _confirmClearData(context, ref),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Clear All Data',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.red)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Permanently delete all accounts, debts, and investments',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.inkDim),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkDim),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
        const _Footer(),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Future<void> _openNameSheet(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NameSheet(
        initial: settings.safeUserName,
        onSave: (name) async {
          final updated = await ref.read(settingsRepoProvider).get();
          updated.userName = name;
          await ref.read(settingsRepoProvider).save(updated);
          ref.invalidate(settingsProvider);
          await HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Future<void> _openIncomeSheet(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IncomeSheet(
        initial: settings.safeMonthlyIncome,
        currency: settings.safeBaseCurrency,
        onSave: (income) async {
          final updated = await ref.read(settingsRepoProvider).get();
          updated.monthlyIncome = income;
          await ref.read(settingsRepoProvider).save(updated);
          ref.invalidate(settingsProvider);
          await HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Future<void> _openPayDateSheet(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PayDateSheet(
        initial: settings.safePayDate,
        onSave: (day) async {
          final updated = await ref.read(settingsRepoProvider).get();
          updated.payDate = day;
          await ref.read(settingsRepoProvider).save(updated);
          ref.invalidate(settingsProvider);
          await HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Future<void> _saveCurrency(
    WidgetRef ref,
    AppSettings settings,
    String currency,
  ) async {
    final updated = await ref.read(settingsRepoProvider).get();
    updated.baseCurrency = currency;
    await ref.read(settingsRepoProvider).save(updated);
    ref.invalidate(settingsProvider);
    await HapticFeedback.lightImpact();
  }

  Future<void> _confirmClearData(BuildContext context, WidgetRef ref) async {
    final step1 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Clear all data?',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently delete all accounts, debts, investments, and debts.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (step1 != true || !context.mounted) return;

    final step2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Are you absolutely sure?',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.red, fontWeight: FontWeight.w600)),
        content: Text(
          'This cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete everything',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (step2 != true || !context.mounted) return;

    await HapticFeedback.vibrate();
    final isar = ref.read(isarProvider);
    await clearAllData(isar);
    await seedDemoData(isar);
    ref.invalidate(settingsProvider);
  }
}

class _CurrencyChips extends StatelessWidget {
  const _CurrencyChips({required this.selected, required this.onSelect});

  final String selected;
  final Future<void> Function(String) onSelect;

  static const _currencies = [
    ('INR', '🇮🇳'),
    ('USD', '🇺🇸'),
    ('GBP', '🇬🇧'),
    ('AED', '🇦🇪'),
    ('SGD', '🇸🇬'),
    ('AUD', '🇦🇺'),
    ('EUR', '🇪🇺'),
  ];

  @override
  Widget build(BuildContext context) {
    return MudraCard(
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _currencies.map((entry) {
          final (code, flag) = entry;
          final isSelected = code == selected;
          return GestureDetector(
            onTap: isSelected ? null : () => onSelect(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected ? AppColors.gold : AppColors.border,
                ),
              ),
              child: Text(
                '$flag  $code',
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.ink,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Mudra',
          style: AppTypography.displaySmall.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'your money, clear.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'v1.0.0',
          style: AppTypography.monoXSmall.copyWith(color: AppColors.inkDim),
        ),
      ],
    );
  }
}

// ── Sheets ────────────────────────────────────────────────────────────────────

class _NameSheet extends StatefulWidget {
  const _NameSheet({required this.initial, required this.onSave});

  final String initial;
  final Future<void> Function(String) onSave;

  @override
  State<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<_NameSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.lg,
          AppSpacing.screenH,
          AppSpacing.screenV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Your Name',
                      style: AppTypography.headingMedium
                          .copyWith(color: AppColors.gold)),
                ),
                IconButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.inkDim),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            MudraInput(
              label: 'Name',
              controller: _controller,
              hintText: 'What should we call you?',
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: MudraButton(
                    label: 'Cancel',
                    variant: MudraButtonVariant.secondary,
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: MudraButton(
                    label: _saving ? 'Saving...' : 'Save',
                    onPressed: _saving ? null : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    await widget.onSave(_controller.text.trim());
    if (mounted) Navigator.of(context).pop();
  }
}

class _IncomeSheet extends StatefulWidget {
  const _IncomeSheet({
    required this.initial,
    required this.currency,
    required this.onSave,
  });

  final double initial;
  final String currency;
  final Future<void> Function(double) onSave;

  @override
  State<_IncomeSheet> createState() => _IncomeSheetState();
}

class _IncomeSheetState extends State<_IncomeSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initial == 0 ? '' : widget.initial.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.lg,
          AppSpacing.screenH,
          AppSpacing.screenV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Monthly Income',
                      style: AppTypography.headingMedium
                          .copyWith(color: AppColors.gold)),
                ),
                IconButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.inkDim),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            MudraInput(
              label:
                  'Income amount (${CurrencyFormatter.symbol(widget.currency)})',
              controller: _controller,
              hintText: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              amountMode: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: MudraButton(
                    label: 'Cancel',
                    variant: MudraButtonVariant.secondary,
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: MudraButton(
                    label: _saving ? 'Saving...' : 'Save',
                    onPressed: _saving ? null : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final parsed = double.tryParse(_controller.text.trim());
    if (parsed == null || parsed < 0) {
      await HapticFeedback.vibrate();
      return;
    }
    setState(() => _saving = true);
    await widget.onSave(parsed);
    if (mounted) Navigator.of(context).pop();
  }
}

class _PayDateSheet extends StatefulWidget {
  const _PayDateSheet({required this.initial, required this.onSave});

  final int initial;
  final Future<void> Function(int) onSave;

  @override
  State<_PayDateSheet> createState() => _PayDateSheetState();
}

class _PayDateSheetState extends State<_PayDateSheet> {
  late int _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.screenV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Pay Date',
                    style: AppTypography.headingMedium
                        .copyWith(color: AppColors.gold)),
              ),
              IconButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.inkDim),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your salary arrives on day $_selected of every month.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: List.generate(31, (i) {
              final day = i + 1;
              final isSelected = day == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.gold : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isSelected ? AppColors.gold : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '$day',
                    style: AppTypography.monoSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.ink,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: MudraButton(
                  label: 'Cancel',
                  variant: MudraButtonVariant.secondary,
                  onPressed:
                      _saving ? null : () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: MudraButton(
                  label: _saving ? 'Saving...' : 'Save',
                  onPressed: _saving ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    await widget.onSave(_selected);
    if (mounted) Navigator.of(context).pop();
  }
}
