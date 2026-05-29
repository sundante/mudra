import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/variable_expense.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/variable_expense_provider.dart';
import '../../widgets/charts/asset_allocation_donut.dart';
import '../../widgets/charts/spend_bar_chart.dart';
import '../../widgets/charts/sparkline_chart.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/hero_stat.dart';
import '../../widgets/common/mudra_hero_card.dart';
import '../../widgets/common/quick_spend_sheet.dart';
import '../../widgets/common/section_label.dart';

// ── Category colour mapping ────────────────────────────────────────────────

Color _categoryColor(VariableCategory cat) => switch (cat) {
      VariableCategory.food => AppColors.red,
      VariableCategory.transport => AppColors.amber,
      VariableCategory.shopping => AppColors.blue,
      VariableCategory.health => AppColors.green,
      VariableCategory.entertainment => AppColors.amber,
      VariableCategory.misc => AppColors.inkDim,
    };

// ── Helpers ────────────────────────────────────────────────────────────────

List<SpendMonthData> _buildMonthData(List<VariableExpense> all) {
  final now = DateTime.now();
  return List.generate(6, (i) {
    final m = DateTime(now.year, now.month - 5 + i);
    final total = all
        .where((e) =>
            e.safeSpentAt.year == m.year && e.safeSpentAt.month == m.month)
        .fold<double>(0, (s, e) => s + e.safeAmount);
    const labels = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return SpendMonthData(month: m, amount: total, label: labels[m.month - 1]);
  });
}

List<SparklinePoint> _buildSparkline(List<VariableExpense> current) {
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  double cumulative = 0;
  return List.generate(daysInMonth, (i) {
    final day = i + 1;
    cumulative += current
        .where((e) => e.safeSpentAt.day == day)
        .fold<double>(0, (s, e) => s + e.safeAmount);
    return SparklinePoint(day: day, amount: cumulative);
  });
}

// ── Screen ─────────────────────────────────────────────────────────────────

class SpendScreen extends ConsumerWidget {
  const SpendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardNotifierProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currency = settings?.safeBaseCurrency ?? 'INR';

    final currentMonth =
        ref.watch(variableExpensesProvider).valueOrNull ?? [];
    final last6Months =
        ref.watch(variableExpensesLast6MonthsProvider).valueOrNull ?? [];

    final now = DateTime.now();

    // Totals
    final totalSpent = currentMonth.fold<double>(0, (s, e) => s + e.safeAmount);

    // Month data for bar chart
    final monthData = _buildMonthData(last6Months);

    // Sparkline
    final sparkPoints = _buildSparkline(currentMonth);

    // Category totals for donut + progress
    final catTotals = <VariableCategory, double>{};
    for (final e in currentMonth) {
      catTotals[e.safeCategory] =
          (catTotals[e.safeCategory] ?? 0) + e.safeAmount;
    }
    final catEntries = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        onPressed: () => _openQuickSpend(context, ref, currency),
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            title: Text('Spending',
                style: AppTypography.headingMedium
                    .copyWith(color: AppColors.red)),
          ),

          // ── Hero Card ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH, AppSpacing.md,
                  AppSpacing.screenH, 0),
              child: MudraHeroCard(
                label: 'SPENT THIS MONTH',
                amount: CurrencyFormatter.compact(totalSpent, currency),
                sublabel:
                    'of ${CurrencyFormatter.compact(dashboard.bankBalance, currency)} liquid',
                bottom: Row(
                  children: [
                    HeroStat(label: 'TRANSACTIONS', value: '${currentMonth.length}', color: Colors.white, onDarkBackground: true),
                    Container(width: 1, height: 28, color: Colors.white24),
                    HeroStat(label: 'CATEGORIES', value: '${catTotals.length}', color: Colors.white, onDarkBackground: true),
                    Container(width: 1, height: 28, color: Colors.white24),
                    HeroStat(label: 'THIS MONTH', value: '${_monthShort(now.month)} ${now.year}', color: Colors.white, onDarkBackground: true),
                  ],
                ),
              ),
            ),
          ),

          // ── 6-Month Bar Chart ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH, AppSpacing.lg,
                  AppSpacing.screenH, 0),
              child: MudraCard(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('monthly spend'),
                    const SizedBox(height: AppSpacing.md),
                    SpendBarChart(months: monthData, currency: CurrencyFormatter.symbol(currency)),
                  ],
                ),
              ),
            ),
          ),

          // ── Category Donut ────────────────────────────────────────────────
          if (catEntries.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, AppSpacing.md,
                    AppSpacing.screenH, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('this month by category'),
                    const SizedBox(height: AppSpacing.sm),
                    AssetAllocationDonut(
                      currency: currency,
                      segments: catEntries
                          .map((e) => DonutSegment(
                                label: e.key.label,
                                value: e.value,
                                color: _categoryColor(e.key),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

          // ── Category Progress Bars ────────────────────────────────────────
          if (catEntries.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, AppSpacing.md,
                    AppSpacing.screenH, 0),
                child: MudraCard(
  
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('category breakdown'),
                      const SizedBox(height: AppSpacing.md),
                      ...catEntries.map((e) => _CategoryProgressRow(
                            category: e.key,
                            amount: e.value,
                            total: totalSpent,
                            currency: currency,
                          )),
                    ],
                  ),
                ),
              ),
            ),

          // ── Sparkline Trend ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH, AppSpacing.md,
                  AppSpacing.screenH, 0),
              child: MudraCard(

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionLabel('spend trend this month'),
                        Text(
                          CurrencyFormatter.compact(totalSpent, currency),
                          style: AppTypography.monoSmall
                              .copyWith(color: AppColors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SparklineChart(points: sparkPoints),
                  ],
                ),
              ),
            ),
          ),

          // ── Recent Expenses ───────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenH, AppSpacing.md,
                  AppSpacing.screenH, 0),
              child: SectionLabel('recent expenses'),
            ),
          ),

          if (currentMonth.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.screenV),
                child: EmptyState(
                  icon: '🧾',
                  title: 'No expenses yet',
                  message: 'Tap + to log your first spend',
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final e = currentMonth[index];
                  return _ExpenseRow(expense: e, currency: currency);
                },
                childCount: currentMonth.length,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl + 72),
          ),
        ],
      ),
    );
  }

  void _openQuickSpend(BuildContext context, WidgetRef ref, String currency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickSpendSheet(
        currency: currency,
        onSave: (draft) async {
          final expense = VariableExpense()
            ..amount = draft.amount
            ..category = draft.category
            ..note = draft.note.isEmpty ? null : draft.note
            ..spentAt = draft.spentAt
            ..createdAt = DateTime.now();
          await ref.read(variableExpenseRepoProvider).save(expense);
        },
      ),
    );
  }

  String _monthShort(int m) =>
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];
}

// ── Category Progress Row ─────────────────────────────────────────────────

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({
    required this.category,
    required this.amount,
    required this.total,
    required this.currency,
  });
  final VariableCategory category;
  final double amount;
  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    final color = _categoryColor(category);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(category.emoji,
              style: const TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category.label,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.ink)),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}%',
                      style: AppTypography.monoXSmall.copyWith(color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            CurrencyFormatter.compact(amount, currency),
            style: AppTypography.monoXSmall.copyWith(color: AppColors.inkDim),
          ),
        ],
      ),
    );
  }
}

// ── Expense Row ───────────────────────────────────────────────────────────

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.expense, required this.currency});
  final VariableExpense expense;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH, vertical: 3),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _categoryColor(expense.safeCategory).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(expense.safeCategory.emoji,
                  style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.safeCategory.label,
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                if (expense.safeNote.isNotEmpty)
                  Text(expense.safeNote,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.inkDim),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.compact(expense.safeAmount, currency),
                style: AppTypography.monoSmall
                    .copyWith(color: AppColors.red),
              ),
              Text(
                '${expense.safeSpentAt.day} ${_monthShort(expense.safeSpentAt.month)}',
                style: AppTypography.monoXSmall
                    .copyWith(color: AppColors.inkDim),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthShort(int m) =>
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];
}
