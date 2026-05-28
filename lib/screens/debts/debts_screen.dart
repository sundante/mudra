import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/debt.dart';
import '../../data/models/outgoing.dart';
import '../../data/models/variable_expense.dart';
import '../../providers/fab_trigger_provider.dart';
import '../../providers/investment_provider.dart';
import '../../providers/outgoing_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/variable_expense_provider.dart';
import '../../widgets/common/amount_display.dart';
import '../../widgets/common/mudra_button.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/mudra_input.dart';
import '../../widgets/common/section_label.dart';
import '../../widgets/outgoing_row.dart';

const _uuid = Uuid();

// ── Category helpers ──────────────────────────────────────────────────────────

Color _categoryColor(OutgoingCategory cat) => switch (cat) {
      OutgoingCategory.sip ||
      OutgoingCategory.ppf ||
      OutgoingCategory.epf ||
      OutgoingCategory.nps ||
      OutgoingCategory.insurance ||
      OutgoingCategory.policyPremium =>
        AppColors.green,
      OutgoingCategory.subscription => AppColors.amber,
      _ => AppColors.red,
    };

String _categoryLabel(OutgoingCategory cat) => switch (cat) {
      OutgoingCategory.loan => 'Loan',
      OutgoingCategory.loanEmi => 'EMI',
      OutgoingCategory.insurance => 'Insurance',
      OutgoingCategory.policyPremium => 'Premium',
      OutgoingCategory.utility => 'Utility',
      OutgoingCategory.subscription => 'Subscription',
      OutgoingCategory.sip => 'SIP',
      OutgoingCategory.ppf => 'PPF',
      OutgoingCategory.epf => 'EPF',
      OutgoingCategory.nps => 'NPS',
      OutgoingCategory.familyPayment => 'Family',
      OutgoingCategory.other => 'Other',
    };

// Groups: (title, categories, colour)
const _outgoingGroups = [
  (
    'LOANS & EMIs',
    [OutgoingCategory.loan, OutgoingCategory.loanEmi],
    AppColors.red
  ),
  (
    'INSURANCE & PREMIUMS',
    [OutgoingCategory.insurance, OutgoingCategory.policyPremium],
    AppColors.green
  ),
  ('SUBSCRIPTIONS', [OutgoingCategory.subscription], AppColors.amber),
  ('UTILITIES & BILLS', [OutgoingCategory.utility], AppColors.red),
  (
    'INVESTMENTS (SIPs)',
    [
      OutgoingCategory.sip,
      OutgoingCategory.ppf,
      OutgoingCategory.epf,
      OutgoingCategory.nps
    ],
    AppColors.green
  ),
  (
    'FAMILY & PERSONAL',
    [OutgoingCategory.familyPayment, OutgoingCategory.other],
    AppColors.red
  ),
];

const _expenseSuggestions = <String>[
  'Home Loan EMI',
  'Car Loan EMI',
  'Rent',
  'Electricity Bill',
  'Wi-Fi',
  'Netflix',
  'Spotify',
  'LIC Premium',
  'Health Insurance',
];

const _investmentSuggestions = <String>[
  'Mutual Fund SIP',
  'PPF Contribution',
  'NPS Auto Debit',
  'EPF Top Up',
  'Gold Savings',
];

const _expenseCategories = <OutgoingCategory>[
  OutgoingCategory.loanEmi,
  OutgoingCategory.loan,
  OutgoingCategory.insurance,
  OutgoingCategory.policyPremium,
  OutgoingCategory.utility,
  OutgoingCategory.subscription,
  OutgoingCategory.familyPayment,
  OutgoingCategory.other,
];

const _investmentCategories = <OutgoingCategory>[
  OutgoingCategory.sip,
  OutgoingCategory.ppf,
  OutgoingCategory.epf,
  OutgoingCategory.nps,
  OutgoingCategory.other,
];

// ── Screen ────────────────────────────────────────────────────────────────────

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen(fabTriggerProvider, (_, next) {
      if (next.$1 == 2 && mounted) {
        _openOutgoingSheet(context, defaultType: OutgoingType.expense);
      }
    });

    final outgoings = ref.watch(outgoingsStreamProvider).valueOrNull ?? [];
    final debts = ref.watch(debtsStreamProvider).valueOrNull ?? [];
    final variableExpenses =
        ref.watch(variableExpensesProvider).valueOrNull ?? [];
    final settings = ref.watch(settingsProvider).valueOrNull ?? AppSettings();
    final currency = settings.safeBaseCurrency;

    final activeItems = outgoings
        .map(_OutgoingView.fromOutgoing)
        .where((o) => o.isActive)
        .toList();

    final totalCommitted = activeItems.fold<double>(0, (s, o) => s + o.amount);

    final upcoming = activeItems.where((o) => o.daysUntil <= 7).toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    final iOweDebts =
        debts.where((d) => d.safeDirection == DebtDirection.iOwe).toList();
    final owedToMeDebts =
        debts.where((d) => d.safeDirection == DebtDirection.theyOwe).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Debts',
          style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.inkDim),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.screenV,
                AppSpacing.screenH,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Summary stat row ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: MudraCard.primary(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionLabel('committed'),
                              const SizedBox(height: 4),
                              AmountDisplay(
                                amount: totalCommitted,
                                currency: currency,
                                style: AppTypography.monoMedium
                                    .copyWith(color: AppColors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: MudraCard.stat(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionLabel('items'),
                              const SizedBox(height: 4),
                              Text(
                                '${activeItems.length}',
                                style: AppTypography.monoMedium
                                    .copyWith(color: AppColors.ink),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // ── Upcoming featured card ──────────────────────
                  if (upcoming.isEmpty)
                    MudraCard(
                      child: Text(
                        'Nothing due in the next 7 days.',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.inkDim),
                      ),
                    )
                  else
                    _UpcomingFeaturedCard(
                      upcoming: upcoming,
                      currency: currency,
                      onTap: (item) => _openOutgoingSheet(context,
                          initial: item, defaultType: item.type),
                    ),
                ],
              ),
            ),
          ),

          // ── Grouped outgoing sections ────────────────────────────────
          for (final group in _outgoingGroups) ...[
            _GroupSection(
              label: group.$1,
              items: activeItems
                  .where((o) => group.$2.contains(o.category))
                  .toList()
                ..sort((a, b) => a.debitDate.compareTo(b.debitDate)),
              color: group.$3,
              currency: currency,
              onTap: (item) => _openOutgoingSheet(context,
                  initial: item, defaultType: item.type),
              onDelete: (id) => _deleteOutgoing(id),
              onConfirmDelete: (item) => _confirmDelete(context, item),
            ),
          ],

          _VariableSpendSection(
            expenses: variableExpenses,
            currency: currency,
            onDelete: _deleteVariableExpense,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.md,
                AppSpacing.screenH,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Expanded(child: SectionLabel('PERSONAL DEBTS')),
                  TextButton.icon(
                    onPressed: () => _openDebtSheet(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Debt'),
                  ),
                ],
              ),
            ),
          ),

          // ── I Owe section ────────────────────────────────────────────
          _DebtGroupSection(
            label: 'I OWE',
            debts: iOweDebts,
            currency: currency,
            color: AppColors.red,
            onTap: (debt) => _openDebtSheet(context,
                debt: _DebtView(
                  id: debt.id,
                  uid: debt.safeUid,
                  counterpartyName: debt.safeCounterpartyName,
                  direction: debt.safeDirection,
                  amount: debt.safeAmount,
                  dueDate: debt.dueDate,
                  notes: debt.safeNotes,
                  isSettled: debt.safeIsSettled,
                  createdAt: ((debt.createdAt as dynamic) as DateTime?) ??
                      DateTime.now(),
                )),
            onDelete: _deleteDebt,
            onMarkSettled: _markSettled,
          ),
          _DebtGroupSection(
            label: 'OWED TO ME',
            debts: owedToMeDebts,
            currency: currency,
            color: AppColors.green,
            onTap: (debt) => _openDebtSheet(context,
                debt: _DebtView(
                  id: debt.id,
                  uid: debt.safeUid,
                  counterpartyName: debt.safeCounterpartyName,
                  direction: debt.safeDirection,
                  amount: debt.safeAmount,
                  dueDate: debt.dueDate,
                  notes: debt.safeNotes,
                  isSettled: debt.safeIsSettled,
                  createdAt: ((debt.createdAt as dynamic) as DateTime?) ??
                      DateTime.now(),
                )),
            onDelete: _deleteDebt,
            onMarkSettled: _markSettled,
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Future<void> _openOutgoingSheet(
    BuildContext context, {
    _OutgoingView? initial,
    required OutgoingType defaultType,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OutgoingEditorSheet(
        initial: initial,
        defaultType: defaultType,
        onSave: _saveOutgoing,
        onDelete: initial == null ? null : () => _deleteOutgoing(initial.id),
      ),
    );
  }

  Future<void> _openDebtSheet(BuildContext context, {_DebtView? debt}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DebtEditorSheet(
        initial: debt,
        onSave: _saveDebt,
        onDelete: debt == null ? null : () => _deleteDebt(debt.id),
      ),
    );
  }

  Future<void> _saveOutgoing(_OutgoingDraft draft) async {
    final repo = ref.read(outgoingRepoProvider);
    final outgoing = Outgoing()
      ..id = draft.id ?? Isar.autoIncrement
      ..uid = draft.uid
      ..name = draft.name
      ..outgoingType = draft.type
      ..category = draft.category
      ..amount = draft.amount
      ..debitDate = draft.debitDate
      ..isActive = draft.isActive
      ..createdAt = draft.createdAt;
    await repo.save(outgoing);
    await HapticFeedback.lightImpact();
  }

  Future<void> _deleteOutgoing(int id) async {
    await ref.read(outgoingRepoProvider).delete(id);
    await HapticFeedback.mediumImpact();
  }

  Future<void> _saveDebt(_DebtDraft draft) async {
    final repo = ref.read(investmentRepoProvider);
    final debt = Debt()
      ..id = draft.id ?? Isar.autoIncrement
      ..uid = draft.uid
      ..counterpartyName = draft.counterpartyName
      ..direction = draft.direction
      ..amount = draft.amount
      ..dueDate = draft.dueDate
      ..notes = draft.notes
      ..isSettled = draft.isSettled
      ..createdAt = draft.createdAt;
    await repo.saveDebt(debt);
    await HapticFeedback.lightImpact();
  }

  Future<void> _deleteDebt(int id) async {
    await ref.read(investmentRepoProvider).deleteDebt(id);
    await HapticFeedback.mediumImpact();
  }

  Future<void> _deleteVariableExpense(int id) async {
    await ref.read(variableExpenseRepoProvider).delete(id);
    await HapticFeedback.mediumImpact();
  }

  Future<void> _markSettled(int id) async {
    await ref.read(investmentRepoProvider).settleDebt(id);
    await HapticFeedback.mediumImpact();
  }

  Future<bool> _confirmDelete(BuildContext context, _OutgoingView item) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Delete ${item.name}?',
                style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.ink, fontWeight: FontWeight.w600)),
            content: Text(
              'This removes the item from monthly projections.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete',
                      style: TextStyle(color: AppColors.red))),
            ],
          ),
        ) ??
        false;
  }
}

// ── Upcoming featured card ────────────────────────────────────────────────────

class _UpcomingFeaturedCard extends StatelessWidget {
  const _UpcomingFeaturedCard({
    required this.upcoming,
    required this.currency,
    required this.onTap,
  });

  final List<_OutgoingView> upcoming;
  final String currency;
  final void Function(_OutgoingView) onTap;

  @override
  Widget build(BuildContext context) {
    final next = upcoming.first;
    final extra = upcoming.length - 1;
    final color = _categoryColor(next.category);

    return MudraCard.primary(
      onTap: () => onTap(next),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('next due'),
                const SizedBox(height: 4),
                Text(
                  next.name,
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  next.daysUntil == 0
                      ? 'Today · Day ${next.debitDate}'
                      : next.daysUntil == 1
                          ? 'Tomorrow · Day ${next.debitDate}'
                          : 'in ${next.daysUntil} days · Day ${next.debitDate}',
                  style:
                      AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
                ),
                if (extra > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+$extra more this week',
                    style: AppTypography.monoXSmall
                        .copyWith(color: AppColors.inkDim),
                  ),
                ],
              ],
            ),
          ),
          AmountDisplay(
            amount: next.amount,
            currency: currency,
            style: AppTypography.monoMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Group section (Outgoings) ─────────────────────────────────────────────────

class _GroupSection extends StatefulWidget {
  const _GroupSection({
    required this.label,
    required this.items,
    required this.color,
    required this.currency,
    required this.onTap,
    required this.onDelete,
    required this.onConfirmDelete,
  });

  final String label;
  final List<_OutgoingView> items;
  final Color color;
  final String currency;
  final void Function(_OutgoingView) onTap;
  final void Function(int id) onDelete;
  final Future<bool> Function(_OutgoingView) onConfirmDelete;

  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  static const _pageSize = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final total = widget.items.fold<double>(0, (s, o) => s + o.amount);
    final visible = _expanded || widget.items.length <= _pageSize
        ? widget.items
        : widget.items.take(_pageSize).toList();
    final hidden = widget.items.length - visible.length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH, 0, AppSpacing.screenH, AppSpacing.sm),
        child: MudraCard(
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SectionLabel(widget.label),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${widget.items.length}',
                      style: AppTypography.monoXSmall
                          .copyWith(color: widget.color),
                    ),
                  ),
                  const Spacer(),
                  AmountDisplay(
                    amount: total,
                    currency: widget.currency,
                    style: AppTypography.monoSmall
                        .copyWith(color: widget.color),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...visible.map((item) => Dismissible(
                    key: ValueKey('outgoing-${item.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.red, size: 18),
                    ),
                    confirmDismiss: (_) => widget.onConfirmDelete(item),
                    onDismissed: (_) => widget.onDelete(item.id),
                    child: OutgoingRow(
                      name: item.name,
                      categoryLabel: _categoryLabel(item.category),
                      debitDate: item.debitDate,
                      daysUntil: item.daysUntil,
                      amount: item.amount,
                      currency: widget.currency,
                      accentColor: widget.color,
                      onTap: () => widget.onTap(item),
                    ),
                  )),
              if (hidden > 0)
                TextButton(
                  onPressed: () => setState(() => _expanded = true),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Show $hidden more',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.gold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Variable spend section ───────────────────────────────────────────────────

class _VariableSpendSection extends StatelessWidget {
  const _VariableSpendSection({
    required this.expenses,
    required this.currency,
    required this.onDelete,
  });

  final List<VariableExpense> expenses;
  final String currency;
  final Future<void> Function(int id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final total =
        expenses.fold<double>(0, (sum, e) => sum + e.safeAmount);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          0,
          AppSpacing.screenH,
          AppSpacing.sm,
        ),
        child: MudraCard(
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SectionLabel('VARIABLE SPENT'),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.redLight,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text('${expenses.length}',
                        style: AppTypography.monoXSmall
                            .copyWith(color: AppColors.red)),
                  ),
                  const Spacer(),
                  AmountDisplay(
                    amount: total,
                    currency: currency,
                    style: AppTypography.monoSmall.copyWith(color: AppColors.red),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...expenses.map((expense) => Dismissible(
                    key: ValueKey('variable-expense-${expense.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.red, size: 18),
                    ),
                    confirmDismiss: (_) => _confirmDelete(context, expense),
                    onDismissed: (_) => onDelete(expense.id),
                    child: _VariableSpendRow(
                        expense: expense, currency: currency),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    VariableExpense expense,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              'Delete ${expense.safeCategory.label} spend?',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'This restores the amount in monthly projections.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _VariableSpendRow extends StatelessWidget {
  const _VariableSpendRow({required this.expense, required this.currency});

  final VariableExpense expense;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            expense.safeCategory.emoji,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.safeCategory.label,
                  style:
                      AppTypography.bodyMedium.copyWith(color: AppColors.ink),
                ),
                if (expense.safeNote.isNotEmpty)
                  Text(
                    expense.safeNote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.inkDim),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _spentDateLabel(expense.safeSpentAt),
                style:
                    AppTypography.monoXSmall.copyWith(color: AppColors.inkDim),
              ),
              AmountDisplay(
                amount: expense.safeAmount,
                currency: currency,
                style: AppTypography.monoSmall.copyWith(color: AppColors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _spentDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final value = DateTime(date.year, date.month, date.day);
    if (value == today) return 'Today';
    if (value == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

// ── Debt group section ────────────────────────────────────────────────────────

class _DebtGroupSection extends StatelessWidget {
  const _DebtGroupSection({
    required this.label,
    required this.debts,
    required this.currency,
    required this.color,
    required this.onTap,
    required this.onDelete,
    required this.onMarkSettled,
  });

  final String label;
  final List<Debt> debts;
  final String currency;
  final Color color;
  final void Function(Debt) onTap;
  final void Function(int) onDelete;
  final void Function(int) onMarkSettled;

  @override
  Widget build(BuildContext context) {
    final active = debts.where((debt) => !debt.safeIsSettled).toList();
    final settled = debts.where((debt) => debt.safeIsSettled).toList();
    final total = active.fold<double>(0, (s, d) => s + d.safeAmount);

    if (active.isEmpty && settled.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH, 0, AppSpacing.screenH, AppSpacing.sm),
        child: MudraCard(
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SectionLabel(label),
                  if (active.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text('${active.length}',
                          style: AppTypography.monoXSmall
                              .copyWith(color: color)),
                    ),
                  ],
                  const Spacer(),
                  if (active.isNotEmpty)
                    AmountDisplay(
                      amount: total,
                      currency: currency,
                      style: AppTypography.monoSmall.copyWith(color: color),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...active.map((debt) => _debtTile(context, debt)),
              if (settled.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                SectionLabel('SETTLED (${settled.length})'),
                const SizedBox(height: AppSpacing.xs),
                ...settled.map(
                    (debt) => _debtTile(context, debt, isSettled: true)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _debtTile(
    BuildContext context,
    Debt debt, {
    bool isSettled = false,
  }) {
    Widget deleteBackground() => Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.redLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.red),
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: ValueKey('debt-${debt.id}'),
        direction: isSettled
            ? DismissDirection.endToStart
            : DismissDirection.horizontal,
        background: isSettled
            ? deleteBackground()
            : Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.green,
                ),
              ),
        secondaryBackground: deleteBackground(),
        confirmDismiss: (direction) async {
          if (!isSettled && direction == DismissDirection.startToEnd) {
            onMarkSettled(debt.id);
          } else if (await _confirmDelete(context, debt)) {
            onDelete(debt.id);
          }
          return false;
        },
        child: Opacity(
          opacity: isSettled ? 0.55 : 1,
          child: GestureDetector(
            onTap: () => onTap(debt),
            child: _DebtRow(debt: debt, currency: currency, color: color),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Debt debt) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              'Delete ${debt.safeCounterpartyName}?',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'This removes the debt permanently.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({
    required this.debt,
    required this.currency,
    required this.color,
  });

  final Debt debt;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MudraCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(debt.safeCounterpartyName,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.ink)),
                if (debt.safeNotes.isNotEmpty)
                  Text(debt.safeNotes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.inkDim)),
                if (debt.dueDate != null)
                  Text(
                    'Due ${_fmt(debt.dueDate!)}',
                    style: AppTypography.monoXSmall
                        .copyWith(color: AppColors.inkDim),
                  ),
              ],
            ),
          ),
          AmountDisplay(
            amount: debt.safeAmount,
            currency: currency,
            style: AppTypography.monoSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime date) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${m[date.month - 1]}';
  }
}


// ── View models ───────────────────────────────────────────────────────────────

class _OutgoingView {
  const _OutgoingView({
    required this.id,
    required this.uid,
    required this.name,
    required this.type,
    required this.category,
    required this.amount,
    required this.debitDate,
    required this.isActive,
    required this.createdAt,
    required this.daysUntil,
  });

  final int id;
  final String uid;
  final String name;
  final OutgoingType type;
  final OutgoingCategory category;
  final double amount;
  final int debitDate;
  final bool isActive;
  final DateTime createdAt;
  final int daysUntil;

  factory _OutgoingView.fromOutgoing(Outgoing o) {
    final day = o.safeDebitDate == 0 ? 1 : o.safeDebitDate;
    return _OutgoingView(
      id: o.id,
      uid: o.safeUid,
      name: o.safeName,
      type: o.safeType,
      category: o.safeCategory,
      amount: o.safeAmount,
      debitDate: day,
      isActive: o.safeIsActive,
      createdAt: o.safeCreatedAt,
      daysUntil: DateHelpers.daysUntilDebit(day),
    );
  }
}

class _DebtView {
  const _DebtView({
    required this.id,
    required this.uid,
    required this.counterpartyName,
    required this.direction,
    required this.amount,
    required this.dueDate,
    required this.notes,
    required this.isSettled,
    required this.createdAt,
  });

  final int id;
  final String uid;
  final String counterpartyName;
  final DebtDirection direction;
  final double amount;
  final DateTime? dueDate;
  final String notes;
  final bool isSettled;
  final DateTime createdAt;
}

class _OutgoingDraft {
  const _OutgoingDraft({
    this.id,
    required this.uid,
    required this.name,
    required this.type,
    required this.category,
    required this.amount,
    required this.debitDate,
    required this.isActive,
    required this.createdAt,
  });

  final int? id;
  final String uid;
  final String name;
  final OutgoingType type;
  final OutgoingCategory category;
  final double amount;
  final int debitDate;
  final bool isActive;
  final DateTime createdAt;
}

class _DebtDraft {
  const _DebtDraft({
    this.id,
    required this.uid,
    required this.counterpartyName,
    required this.direction,
    required this.amount,
    this.dueDate,
    this.notes,
    required this.isSettled,
    required this.createdAt,
  });

  final int? id;
  final String uid;
  final String counterpartyName;
  final DebtDirection direction;
  final double amount;
  final DateTime? dueDate;
  final String? notes;
  final bool isSettled;
  final DateTime createdAt;
}

// ── Outgoing editor sheet ─────────────────────────────────────────────────────

class _OutgoingEditorSheet extends ConsumerStatefulWidget {
  const _OutgoingEditorSheet({
    required this.initial,
    required this.defaultType,
    required this.onSave,
    required this.onDelete,
  });

  final _OutgoingView? initial;
  final OutgoingType defaultType;
  final Future<void> Function(_OutgoingDraft) onSave;
  final Future<void> Function()? onDelete;

  @override
  ConsumerState<_OutgoingEditorSheet> createState() =>
      _OutgoingEditorSheetState();
}

class _OutgoingEditorSheetState extends ConsumerState<_OutgoingEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late OutgoingType _type;
  late OutgoingCategory _category;
  late int _debitDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameController = TextEditingController(text: i?.name ?? '');
    _amountController = TextEditingController(
        text: i == null ? '' : i.amount.toStringAsFixed(2));
    _type = i?.type ?? widget.defaultType;
    _category = _resolveCategory(i?.category, _type);
    _debitDate = i?.debitDate ?? DateTime.now().day;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    final categories = _type == OutgoingType.expense
        ? _expenseCategories
        : _investmentCategories;
    final suggestions = _type == OutgoingType.expense
        ? _expenseSuggestions
        : _investmentSuggestions;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.lg,
              AppSpacing.screenH, AppSpacing.screenV),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Commitment' : 'Add Commitment',
                        style: AppTypography.headingMedium
                            .copyWith(color: AppColors.gold),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.inkDim),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<OutgoingType>(
                  segments: const [
                    ButtonSegment(
                        value: OutgoingType.expense, label: Text('Expense')),
                    ButtonSegment(
                        value: OutgoingType.investment,
                        label: Text('Investment')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() {
                    _type = s.first;
                    _category = _resolveCategory(null, _type);
                  }),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: WidgetStateProperty.resolveWith((s) =>
                        s.contains(WidgetState.selected)
                            ? Colors.white
                            : AppColors.ink),
                    backgroundColor: WidgetStateProperty.resolveWith((s) =>
                        s.contains(WidgetState.selected)
                            ? AppColors.gold
                            : AppColors.surface),
                    side: const WidgetStatePropertyAll(
                        BorderSide(color: AppColors.border)),
                    textStyle:
                        WidgetStatePropertyAll(AppTypography.labelMedium),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MudraInput(
                  label: 'Name',
                  controller: _nameController,
                  hintText: _type == OutgoingType.expense
                      ? 'Home Loan EMI'
                      : 'Mutual Fund SIP',
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: suggestions
                      .map((s) => ChoiceChip(
                            label: Text(s),
                            selected: _nameController.text == s,
                            onSelected: (_) =>
                                setState(() => _nameController.text = s),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                MudraInput(
                  label: 'Amount',
                  controller: _amountController,
                  hintText: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  amountMode: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Amount required';
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Category',
                    style: AppTypography.labelMedium.copyWith(
                        color: AppColors.ink, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: categories.map((cat) {
                    final sel = _category == cat;
                    final col = _categoryColor(cat);
                    return ChoiceChip(
                      label: Text(_categoryLabel(cat)),
                      selected: sel,
                      onSelected: (_) => setState(() => _category = cat),
                      selectedColor: col,
                      labelStyle: AppTypography.labelMedium.copyWith(
                          color: sel ? Colors.white : AppColors.inkMid),
                      side: BorderSide(color: sel ? col : AppColors.border),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                MudraCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel('debit day'),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Day $_debitDate of every month',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: AppColors.ink)),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            _saving ? null : () => _pickDebitDate(context),
                        icon:
                            const Icon(Icons.calendar_month_outlined, size: 18),
                        label: const Text('Pick'),
                      ),
                    ],
                  ),
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
                        label: _saving
                            ? (isEditing ? 'Saving...' : 'Creating...')
                            : (isEditing ? 'Save' : 'Add'),
                        onPressed: _saving ? null : _submit,
                      ),
                    ),
                  ],
                ),
                if (widget.onDelete != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  MudraButton(
                    label: 'Delete',
                    variant: MudraButtonVariant.destructive,
                    onPressed: _saving
                        ? null
                        : () async {
                            Navigator.of(context).pop();
                            await widget.onDelete!();
                          },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDebitDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month, _debitDate),
      firstDate: DateTime(now.year, now.month, 1),
      lastDate: DateTime(now.year, now.month + 1, 0),
      helpText: 'Select debit day',
    );
    if (picked != null && mounted) setState(() => _debitDate = picked.day);
  }

  OutgoingCategory _resolveCategory(
      OutgoingCategory? initial, OutgoingType type) {
    final allowed = type == OutgoingType.expense
        ? _expenseCategories
        : _investmentCategories;
    if (initial != null && allowed.contains(initial)) return initial;
    return allowed.first;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      await HapticFeedback.vibrate();
      return;
    }
    setState(() => _saving = true);
    final i = widget.initial;
    await widget.onSave(_OutgoingDraft(
      id: i?.id,
      uid: i != null && i.uid.isNotEmpty ? i.uid : _uuid.v4(),
      name: _nameController.text.trim(),
      type: _type,
      category: _category,
      amount: double.parse(_amountController.text.trim()),
      debitDate: _debitDate,
      isActive: i?.isActive ?? true,
      createdAt: i?.createdAt ?? DateTime.now(),
    ));
    if (mounted) Navigator.of(context).pop();
  }
}

// ── Debt editor sheet ─────────────────────────────────────────────────────────

class _DebtEditorSheet extends StatefulWidget {
  const _DebtEditorSheet({
    required this.initial,
    required this.onSave,
    required this.onDelete,
  });

  final _DebtView? initial;
  final Future<void> Function(_DebtDraft) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<_DebtEditorSheet> createState() => _DebtEditorSheetState();
}

class _DebtEditorSheetState extends State<_DebtEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  DebtDirection _direction = DebtDirection.iOwe;
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameController = TextEditingController(text: i?.counterpartyName ?? '');
    _amountController = TextEditingController(
        text: i == null ? '' : i.amount.toStringAsFixed(2));
    _notesController = TextEditingController(text: i?.notes ?? '');
    _direction = i?.direction ?? DebtDirection.iOwe;
    _dueDate = i?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.lg,
              AppSpacing.screenH, AppSpacing.screenV),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Debt' : 'Add Debt',
                        style: AppTypography.headingMedium
                            .copyWith(color: AppColors.gold),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.inkDim),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<DebtDirection>(
                  segments: const [
                    ButtonSegment(
                        value: DebtDirection.iOwe, label: Text('I Owe')),
                    ButtonSegment(
                        value: DebtDirection.theyOwe, label: Text('They Owe')),
                  ],
                  selected: {_direction},
                  onSelectionChanged: (s) =>
                      setState(() => _direction = s.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: WidgetStateProperty.resolveWith((s) =>
                        s.contains(WidgetState.selected)
                            ? Colors.white
                            : AppColors.ink),
                    backgroundColor: WidgetStateProperty.resolveWith((s) =>
                        s.contains(WidgetState.selected)
                            ? AppColors.gold
                            : AppColors.surface),
                    side: const WidgetStatePropertyAll(
                        BorderSide(color: AppColors.border)),
                    textStyle:
                        WidgetStatePropertyAll(AppTypography.labelMedium),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MudraInput(
                  label: 'Person / Organisation',
                  controller: _nameController,
                  hintText: 'Who?',
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                MudraInput(
                  label: 'Amount',
                  controller: _amountController,
                  hintText: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  amountMode: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Amount required';
                    }
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                MudraInput(
                  label: 'Notes (optional)',
                  controller: _notesController,
                  hintText: 'What for?',
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.md),
                ActionChip(
                  backgroundColor: AppColors.goldLight,
                  side: const BorderSide(color: AppColors.border),
                  avatar: const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.gold),
                  label: Text(
                    _dueDate == null ? 'Set due date' : _fmtDate(_dueDate!),
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.gold),
                  ),
                  onPressed: _saving ? null : _pickDueDate,
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
                        label: _saving
                            ? (isEditing ? 'Saving...' : 'Adding...')
                            : (isEditing ? 'Save' : 'Add'),
                        onPressed: _saving ? null : _submit,
                      ),
                    ),
                  ],
                ),
                if (widget.onDelete != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  MudraButton(
                    label: 'Delete',
                    variant: MudraButtonVariant.destructive,
                    onPressed: _saving
                        ? null
                        : () async {
                            Navigator.of(context).pop();
                            await widget.onDelete!();
                          },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      helpText: 'Select due date',
    );
    if (picked != null && mounted) setState(() => _dueDate = picked);
  }

  String _fmtDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      await HapticFeedback.vibrate();
      return;
    }
    setState(() => _saving = true);
    final i = widget.initial;
    await widget.onSave(_DebtDraft(
      id: i?.id,
      uid: i?.uid ?? _uuid.v4(),
      counterpartyName: _nameController.text.trim(),
      direction: _direction,
      amount: double.parse(_amountController.text.trim()),
      dueDate: _dueDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isSettled: i?.isSettled ?? false,
      createdAt: i?.createdAt ?? DateTime.now(),
    ));
    if (mounted) Navigator.of(context).pop();
  }
}
