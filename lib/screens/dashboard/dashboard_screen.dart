import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/credit.dart';
import '../../data/models/outgoing.dart';
import '../../data/models/variable_expense.dart';
import '../../providers/account_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/investment_provider.dart';
import '../../providers/outgoing_provider.dart';
import '../../providers/selected_day_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/variable_expense_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helpers.dart';
import '../../widgets/charts/asset_allocation_donut.dart';
import '../../widgets/common/amount_display.dart';
import '../../widgets/common/empty_state.dart';
import '../../providers/fab_trigger_provider.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/hero_stat.dart';
import '../../widgets/common/mudra_hero_card.dart';
import '../../widgets/common/section_label.dart';
import '../../widgets/common/quick_spend_sheet.dart';

const _monthShortNames = <String>[
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
const _uuid = Uuid();

String _formatExactMonthDate(int day) {
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final safeDay = day.clamp(1, daysInMonth);
  return '$safeDay ${_monthShortNames[now.month - 1]}';
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(accountsStreamProvider);
    ref.invalidate(outgoingsStreamProvider);
    ref.invalidate(platformsStreamProvider);
    ref.invalidate(debtsStreamProvider);
    ref.invalidate(settingsProvider);
    ref.invalidate(variableExpensesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardNotifierProvider);

    return DefaultTabController(
      length: 2,
      child: RefreshIndicator(
        color: AppColors.red,
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Mudra',
                style:
                    AppTypography.headingMedium.copyWith(color: AppColors.red),
              ),
              actions: [
                IconButton(
                  icon:
                      const Icon(Icons.person_outline, color: AppColors.inkDim),
                  onPressed: () => context.push('/profile'),
                ),
              ],
              bottom: TabBar(
                labelColor: AppColors.red,
                unselectedLabelColor: AppColors.inkDim,
                labelStyle: AppTypography.labelMedium,
                unselectedLabelStyle: AppTypography.labelMedium,
                indicatorColor: AppColors.red,
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: 'This Month'),
                  Tab(text: 'Overall'),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  _ThisMonthTab(dashboard: dashboard),
                  _OverallTab(dashboard: dashboard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── This Month Tab ────────────────────────────────────────────────────────

class _ThisMonthTab extends ConsumerStatefulWidget {
  const _ThisMonthTab({required this.dashboard});
  final DashboardData dashboard;

  @override
  ConsumerState<_ThisMonthTab> createState() => _ThisMonthTabState();
}

class _ThisMonthTabState extends ConsumerState<_ThisMonthTab> {
  Future<void> _pickSimulationDate(
      BuildContext context, int selectedDay) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month, selectedDay),
      firstDate: firstDay,
      lastDate: lastDay,
      helpText: 'Select simulation day',
    );
    if (picked == null || !mounted) return;
    ref.read(selectedDayProvider.notifier).state = picked.day;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(fabTriggerProvider, (_, next) {
      if (next.$1 == 0 && mounted) {
        _openQuickSpendSheet(context, widget.dashboard.currency);
      }
    });

    final dashboard = widget.dashboard;
    final selectedDay = ref.watch(selectedDayProvider);
    final now = DateTime.now();
    final today = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final radarItems = dashboard.debitRadar;
    final showSeeAll = radarItems.length > 5;
    final visibleRadar = radarItems.take(5).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: AppSpacing.screenV,
            bottom: AppSpacing.xxl + 72,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Sticky Date Header ──────────────────────────────────────────
              Sticky(
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenH, vertical: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDateHeader(now),
                            style: AppTypography.labelMedium
                                .copyWith(color: AppColors.inkDim),
                          ),
                          Text(
                            _formatMonth(now),
                            style: AppTypography.headingSmall
                                .copyWith(color: AppColors.red),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _pickSimulationDate(context, selectedDay),
                        icon:
                            const Icon(Icons.calendar_month_outlined, size: 18),
                        label: Text(_formatPickerLabel(now, selectedDay)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: AppTypography.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Spendable Hero Tile ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.screenV,
                  AppSpacing.screenH,
                  0,
                ),
                child: () {
                  final liquid = dashboard.bankBalance;
                  final projected = dashboard.monthRunway;
                  final daysLeft = daysInMonth - today;
                  final liquidColor =
                      liquid >= 0 ? AppColors.green : AppColors.red;
                  final projColor =
                      projected >= 0 ? AppColors.green : AppColors.red;
                  final projSign = projected >= 0 ? '+' : '';
                  return MudraHeroCard(
                    label: 'SPENDABLE THIS MONTH',
                    amount: CurrencyFormatter.compact(liquid, dashboard.currency),
                    amountColor: liquidColor,
                    sublabel: '$daysLeft days left',
                    bottom: Row(
                      children: [
                        HeroStat(
                          label: 'LIQUID',
                          value: CurrencyFormatter.compact(
                              liquid, dashboard.currency),
                          color: liquidColor,
                        ),
                        Container(
                            width: 1, height: 24, color: AppColors.border),
                        HeroStat(
                          label: 'DAYS LEFT',
                          value: '$daysLeft',
                          color: AppColors.inkDim,
                        ),
                        Container(
                            width: 1, height: 24, color: AppColors.border),
                        HeroStat(
                          label: 'PROJECTED',
                          value:
                              '$projSign${CurrencyFormatter.compact(projected, dashboard.currency)}',
                          color: projColor,
                        ),
                      ],
                    ),
                  );
                }(),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Projection Block ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  0,
                ),
                child: _ProjectionBlock(
                  dashboard: dashboard,
                  selectedDay: selectedDay,
                  today: today,
                  daysInMonth: daysInMonth,
                  onDayChanged: (d) =>
                      ref.read(selectedDayProvider.notifier).state = d,
                  onReset: () =>
                      ref.read(selectedDayProvider.notifier).state = today,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Runway Table ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.screenV),
                child: _RunwayTable(
                    dashboard: dashboard, selectedDay: selectedDay),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Quick Stats ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH),
                child: Row(
                  children: [
                    Expanded(
                      child: MudraCard.stat(
                        onTap: () => context.go('/net'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AmountDisplay(
                              amount: dashboard.netWorth,
                              currency: dashboard.currency,
                              style: AppTypography.monoMedium,
                              coloured: true,
                              compact: true,
                            ),
                            const SizedBox(height: 2),
                            const SectionLabel('NET WORTH'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: MudraCard.stat(
                        onTap: () => context.go('/debts'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dashboard.fixedItemsCount}',
                              style: AppTypography.monoMedium
                                  .copyWith(color: AppColors.ink),
                            ),
                            const SizedBox(height: 2),
                            const SectionLabel('FIXED ITEMS'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: MudraCard.stat(
                        onTap: () => context.go('/accounts'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dashboard.accountsCount}',
                              style: AppTypography.monoMedium
                                  .copyWith(color: AppColors.ink),
                            ),
                            const SizedBox(height: 2),
                            const SectionLabel('ACCOUNTS'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Quick Actions ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.screenV),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('quick actions'),
                    const SizedBox(height: AppSpacing.md),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.4,
                      children: [
                        _QuickActionTile(
                          icon: Icons.receipt_long_outlined,
                          label: 'Spending',
                          onTap: () => context.push('/spend'),
                        ),
                        _QuickActionTile(
                          icon: Icons.savings_outlined,
                          label: 'Funds',
                          onTap: () => context.go('/accounts'),
                        ),
                        _QuickActionTile(
                          icon: Icons.account_balance_outlined,
                          label: 'Debts',
                          onTap: () => context.go('/debts'),
                        ),
                        _QuickActionTile(
                          icon: Icons.show_chart_outlined,
                          label: 'Invests',
                          onTap: () => context.go('/portfolio'),
                        ),
                        _QuickActionTile(
                          icon: Icons.donut_large_outlined,
                          label: 'Net Worth',
                          onTap: () => context.go('/net'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Until End of Month ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.screenV),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('until end of month'),
                    const SizedBox(height: AppSpacing.md),
                    if (radarItems.isEmpty)
                      const EmptyState(
                        icon: '✓',
                        title: 'All clear',
                        message: 'No debits until end of month',
                      )
                    else ...[
                      ...visibleRadar.map((item) => _RadarItem(
                            row: item.outgoing,
                            daysUntil: item.daysUntil,
                            currency: dashboard.currency,
                          )),
                      if (showSeeAll)
                        TextButton(
                          onPressed: () => context.go('/debts'),
                          child: Text(
                            'See all in Debits',
                            style: AppTypography.labelMedium
                                .copyWith(color: AppColors.red),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.screenV),
                child: Text(
                  'Pull to refresh',
                  style: AppTypography.monoXSmall
                      .copyWith(color: AppColors.inkDim),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openQuickSpendSheet(
    BuildContext context,
    String currency,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickSpendSheet(
        currency: currency,
        onSave: (draft) async {
          final expense = VariableExpense()
            ..uid = _uuid.v4()
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

  String _formatDateHeader(DateTime now) {
    final weekday =
        ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][now.weekday - 1];
    return '$weekday, ${now.day}';
  }

  String _formatMonth(DateTime now) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER'
    ];
    return months[now.month - 1];
  }

  String _formatPickerLabel(DateTime now, int selectedDay) {
    final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDate = DateTime(now.year, now.month, selectedDay);
    return '${weekday[selectedDate.weekday - 1]}, $selectedDay';
  }
}

class _RunwayTable extends StatelessWidget {
  const _RunwayTable({required this.dashboard, required this.selectedDay});

  final DashboardData dashboard;
  final int selectedDay;

  @override
  Widget build(BuildContext context) {
    final commitmentsTotal =
        dashboard.futureCommitted + dashboard.ccOutstanding;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E0D8)),
      ),
      child: Column(
        children: [
          // Cash in Accounts
          _TableSection(
            title: 'Opening Liquid',
            subtitle: 'derived month baseline',
            total: dashboard.openingLiquidBalance,
            prefix: '',
            totalColor: AppColors.ink,
            body: _OpeningBalanceBody(
              currentLiquidBalance: dashboard.bankBalance,
              openingLiquidBalance: dashboard.openingLiquidBalance,
              variableSpentToDay: dashboard.variableSpentToDay,
              variableExpenseCount: dashboard.variableExpensesToDayCount,
              selectedDay: selectedDay,
              rows: dashboard.liquidRows,
              currency: dashboard.currency,
            ),
          ),

          const Divider(color: Color(0xFFE4E0D8), height: 1),

          // Credits
          _TableSection(
            title: 'Credits Received',
            subtitle: 'as of Day $selectedDay',
            total: dashboard.creditsTotal,
            prefix: '+ ',
            totalColor: AppColors.green,
            body: _CreditsBody(
              received: dashboard.receivedCredits,
              pending: dashboard.pendingCredits,
              currency: dashboard.currency,
            ),
          ),

          const Divider(color: Color(0xFFE4E0D8), height: 1),

          // Debits
          _TableSection(
            title: 'Debits Fired',
            subtitle: 'as of Day $selectedDay',
            total: dashboard.alreadyFired,
            prefix: '− ',
            totalColor: AppColors.inkDim,
            body: _DebitsBody(
                groups: dashboard.firedGroups, currency: dashboard.currency),
          ),

          const Divider(color: Color(0xFFE4E0D8), height: 1),

          // Commitments
          _TableSection(
            title: 'Remaining Commitments',
            subtitle: 'after Day $selectedDay',
            total: commitmentsTotal,
            prefix: '− ',
            totalColor: AppColors.red,
            body: _CommitmentsBody(
              ccOutstanding: dashboard.ccOutstanding,
              futureRows: dashboard.futureRows,
              currency: dashboard.currency,
            ),
            isLast: true,
          ),

          // Result rows
          Container(
            decoration: BoxDecoration(
              color: dashboard.isOvercommitted
                  ? const Color(0xFFF5DBD8)
                  : const Color(0xFFF5ECD4),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance on Day $selectedDay',
                      style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                    AmountDisplay(
                      amount: dashboard.simulatedBalanceOnDay,
                      currency: dashboard.currency,
                      style: AppTypography.monoMedium.copyWith(
                          fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Projected Month End',
                      style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                    AmountDisplay(
                      amount: dashboard.monthRunway,
                      currency: dashboard.currency,
                      style: AppTypography.monoMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: dashboard.gaugeColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Table Section (collapsible) ──────────────────────────────────────────

class _TableSection extends StatefulWidget {
  const _TableSection({
    required this.title,
    required this.total,
    required this.prefix,
    required this.totalColor,
    required this.body,
    this.subtitle,
    this.isLast = false,
  });

  final String title;
  final String? subtitle;
  final double total;
  final String prefix;
  final Color totalColor;
  final Widget body;
  final bool isLast;

  @override
  State<_TableSection> createState() => _TableSectionState();
}

class _TableSectionState extends State<_TableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.ink),
                      ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          style: AppTypography.monoXSmall
                              .copyWith(color: AppColors.inkDim),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      widget.prefix,
                      style: AppTypography.monoXSmall
                          .copyWith(color: widget.totalColor),
                    ),
                    AmountDisplay(
                      amount: widget.total,
                      currency: '',
                      style: AppTypography.monoSmall
                          .copyWith(color: widget.totalColor),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.inkDim,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.sm,
                  ),
                  child: widget.body,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─── Section Bodies ───────────────────────────────────────────────────────

class _OpeningBalanceBody extends StatelessWidget {
  const _OpeningBalanceBody({
    required this.currentLiquidBalance,
    required this.openingLiquidBalance,
    required this.variableSpentToDay,
    required this.variableExpenseCount,
    required this.selectedDay,
    required this.rows,
    required this.currency,
  });

  final double currentLiquidBalance;
  final double openingLiquidBalance;
  final double variableSpentToDay;
  final int variableExpenseCount;
  final int selectedDay;
  final List<AccountRow> rows;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SimpleRow(
          label: 'Current liquid total',
          amount: currentLiquidBalance,
          currency: currency,
          color: AppColors.ink,
        ),
        _SimpleRow(
          label: 'Derived opening balance',
          amount: openingLiquidBalance,
          currency: currency,
          color: AppColors.inkDim,
        ),
        if (variableSpentToDay > 0)
          _VariableSpendRow(
            amount: variableSpentToDay,
            count: variableExpenseCount,
            selectedDay: selectedDay,
            currency: currency,
          ),
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Current account balances',
            style: AppTypography.monoXSmall.copyWith(color: AppColors.inkDim),
          ),
          const SizedBox(height: 2),
          ...rows.map((r) => _SimpleRow(
                label: r.nickname,
                amount: r.balance,
                currency: currency,
                color: AppColors.inkDim,
              )),
        ],
      ],
    );
  }
}

class _VariableSpendRow extends StatelessWidget {
  const _VariableSpendRow({
    required this.amount,
    required this.count,
    required this.selectedDay,
    required this.currency,
  });

  final double amount;
  final int count;
  final int selectedDay;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Variable spend',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.inkMid),
                ),
                Text(
                  '$count items through Day $selectedDay',
                  style: AppTypography.monoXSmall
                      .copyWith(color: AppColors.inkDim),
                ),
              ],
            ),
          ),
          Text(
            '− ',
            style: AppTypography.monoSmall.copyWith(color: AppColors.red),
          ),
          AmountDisplay(
            amount: amount,
            currency: currency,
            style: AppTypography.monoSmall.copyWith(color: AppColors.red),
          ),
        ],
      ),
    );
  }
}

class _CreditsBody extends StatelessWidget {
  const _CreditsBody({
    required this.received,
    required this.pending,
    required this.currency,
  });
  final List<CreditRow> received;
  final List<CreditRow> pending;
  final String currency;

  String _categoryLabel(CreditCategory cat) {
    switch (cat) {
      case CreditCategory.salary:
        return 'salary';
      case CreditCategory.interest:
        return 'interest';
      case CreditCategory.refund:
        return 'refund';
      case CreditCategory.cashback:
        return 'cashback';
      case CreditCategory.dividend:
        return 'dividend';
      case CreditCategory.other:
        return 'other';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (received.isEmpty && pending.isEmpty) {
      return Text('No credits recorded',
          style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...received.map((c) => _SimpleRow(
              label: c.name,
              sublabel:
                  '${_formatExactMonthDate(c.creditDate)} · ${_categoryLabel(c.category)}',
              amount: c.amount,
              currency: currency,
              color: AppColors.green,
            )),
        if (pending.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Upcoming',
              style:
                  AppTypography.monoXSmall.copyWith(color: AppColors.inkDim)),
          ...pending.map((c) => _SimpleRow(
                label: c.name,
                sublabel:
                    '${_formatExactMonthDate(c.creditDate)} · ${_categoryLabel(c.category)}',
                amount: c.amount,
                currency: currency,
                color: AppColors.inkDim,
                italic: true,
              )),
        ],
      ],
    );
  }
}

class _DebitsBody extends StatelessWidget {
  const _DebitsBody({required this.groups, required this.currency});
  final List<CategoryGroup> groups;
  final String currency;

  String _categoryLabel(OutgoingCategory cat) {
    switch (cat) {
      case OutgoingCategory.loan:
        return 'Loans';
      case OutgoingCategory.insurance:
        return 'Insurance';
      case OutgoingCategory.utility:
        return 'Utilities';
      case OutgoingCategory.subscription:
        return 'Subscriptions';
      case OutgoingCategory.sip:
        return 'SIPs';
      case OutgoingCategory.ppf:
        return 'PPF';
      case OutgoingCategory.epf:
        return 'EPF';
      case OutgoingCategory.nps:
        return 'NPS';
      case OutgoingCategory.loanEmi:
        return 'Loan EMI';
      case OutgoingCategory.policyPremium:
        return 'Premium';
      case OutgoingCategory.familyPayment:
        return 'Family';
      case OutgoingCategory.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Text('Nothing debited yet',
          style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: groups.expand((g) {
        return [
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SectionLabel(_categoryLabel(g.category)),
                AmountDisplay(
                  amount: g.total,
                  currency: currency,
                  style: AppTypography.monoXSmall
                      .copyWith(color: AppColors.inkDim),
                ),
              ],
            ),
          ),
          ...g.items.map((r) => Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _SimpleRow(
                  label: r.name,
                  sublabel:
                      '${_formatExactMonthDate(r.debitDate)} · ${r.type == OutgoingType.investment ? 'investment' : 'expense'}',
                  amount: r.amount,
                  currency: currency,
                  color: AppColors.inkDim,
                ),
              )),
        ];
      }).toList(),
    );
  }
}

class _CommitmentsBody extends StatelessWidget {
  const _CommitmentsBody({
    required this.ccOutstanding,
    required this.futureRows,
    required this.currency,
  });
  final double ccOutstanding;
  final List<OutgoingRow> futureRows;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (ccOutstanding == 0 && futureRows.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 14, color: AppColors.green),
          const SizedBox(width: 8),
          Text('No commitments remaining',
              style: AppTypography.bodySmall.copyWith(color: AppColors.green)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ccOutstanding > 0)
          _SimpleRow(
            label: 'CC Outstanding',
            amount: ccOutstanding,
            currency: currency,
            color: AppColors.red,
            bold: true,
          ),
        ...futureRows.map((r) {
          final isInv = r.type == OutgoingType.investment;
          return _SimpleRow(
            label: r.name,
            sublabel:
                '${_formatExactMonthDate(r.debitDate)} · ${isInv ? 'investment' : 'expense'}',
            amount: r.amount,
            currency: currency,
            color: isInv ? AppColors.amber : AppColors.red,
          );
        }),
      ],
    );
  }
}

// ─── Simple Row ───────────────────────────────────────────────────────────

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    this.sublabel,
    this.italic = false,
    this.bold = false,
  });

  final String label;
  final String? sublabel;
  final double amount;
  final String currency;
  final Color color;
  final bool italic;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: color,
                    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                    fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (sublabel != null)
                  Text(
                    sublabel!,
                    style: AppTypography.monoXSmall
                        .copyWith(color: AppColors.inkDim),
                  ),
              ],
            ),
          ),
          AmountDisplay(
            amount: amount,
            currency: currency,
            style: AppTypography.monoXSmall.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Radar Item (uses pre-typed OutgoingRow) ───────────────────────────────

class _RadarItem extends StatelessWidget {
  const _RadarItem({
    required this.row,
    required this.daysUntil,
    required this.currency,
  });

  final OutgoingRow row;
  final int daysUntil;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isExpense = row.type == OutgoingType.expense;
    final barColor = isExpense ? AppColors.red : AppColors.amber;
    final urgent = daysUntil <= 2;

    final Color chipBg;
    final Color chipText;
    if (urgent) {
      chipBg = AppColors.redLight;
      chipText = AppColors.red;
    } else if (daysUntil <= 5) {
      chipBg = AppColors.amberLight;
      chipText = AppColors.amber;
    } else {
      chipBg = AppColors.surfaceAlt;
      chipText = AppColors.inkDim;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 3, height: 36, color: barColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.name, style: AppTypography.bodyMedium),
                Text(
                  row.type == OutgoingType.investment
                      ? 'investment'
                      : 'expense',
                  style: AppTypography.monoXSmall
                      .copyWith(color: AppColors.inkDim),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AmountDisplay(
                amount: row.amount,
                currency: currency,
                style: AppTypography.monoSmall,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  DateHelpers.debitLabel(daysUntil),
                  style: AppTypography.monoXSmall.copyWith(color: chipText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sticky Widget (frozen header on scroll) ───────────────────────────────

class Sticky extends StatelessWidget {
  const Sticky({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OverallTab extends StatelessWidget {
  const _OverallTab({required this.dashboard});
  final DashboardData dashboard;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH, vertical: AppSpacing.screenV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => context.go('/net'),
            child: MudraHeroCard(
              label: 'NET WORTH',
              amount: CurrencyFormatter.compact(
                  dashboard.netWorth, dashboard.currency),
              sublabel: dashboard.netWorth >= 0
                  ? 'You\'re in the green'
                  : 'Liabilities exceed assets',
              bottom: Row(
                children: [
                  _HeroDashStat(
                    label: 'ASSETS',
                    value: CurrencyFormatter.compact(
                        dashboard.totalAssets, dashboard.currency),
                    color: AppColors.green,
                  ),
                  Container(width: 1, height: 24, color: AppColors.border),
                  _HeroDashStat(
                    label: 'INVESTED',
                    value: CurrencyFormatter.compact(
                        dashboard.investmentsTotal, dashboard.currency),
                    color: AppColors.amber,
                  ),
                  Container(width: 1, height: 24, color: AppColors.border),
                  _HeroDashStat(
                    label: 'LIABILITIES',
                    value: CurrencyFormatter.compact(
                        dashboard.totalLiabilities, dashboard.currency),
                    color: AppColors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AssetAllocationDonut(
            currency: dashboard.currency,
            segments: [
              DonutSegment(
                label: 'Liquid Cash',
                value: dashboard.bankBalance,
                color: AppColors.green,
              ),
              DonutSegment(
                label: 'Fixed Dep.',
                value: dashboard.fdTotal,
                color: AppColors.blue,
              ),
              DonutSegment(
                label: 'Investments',
                value: dashboard.investmentsTotal,
                color: AppColors.amber,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: MudraCard.stat(
                  onTap: () => context.go('/accounts'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AmountDisplay(
                        amount: dashboard.totalAssets,
                        currency: dashboard.currency,
                        style: AppTypography.monoMedium,
                        compact: true,
                      ),
                      const SizedBox(height: 2),
                      const SectionLabel('ASSETS'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MudraCard.stat(
                  onTap: () => context.go('/portfolio'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AmountDisplay(
                        amount: dashboard.investmentsTotal,
                        currency: dashboard.currency,
                        style: AppTypography.monoMedium
                            .copyWith(color: AppColors.amber),
                        compact: true,
                      ),
                      const SizedBox(height: 2),
                      const SectionLabel('INVESTED'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MudraCard.stat(
                  onTap: () => context.go('/portfolio'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AmountDisplay(
                        amount: dashboard.totalLiabilities,
                        currency: dashboard.currency,
                        style: AppTypography.monoMedium
                            .copyWith(color: AppColors.red),
                        compact: true,
                      ),
                      const SizedBox(height: 2),
                      const SectionLabel('LIABILITIES'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('assets breakdown'),
          const SizedBox(height: AppSpacing.md),
          _BreakdownRow(
              label: 'Liquid Cash',
              amount: dashboard.bankBalance,
              currency: dashboard.currency),
          _BreakdownRow(
              label: 'Fixed Deposits',
              amount: dashboard.fdTotal,
              currency: dashboard.currency),
          _BreakdownRow(
              label: 'Investments',
              amount: dashboard.investmentsTotal,
              currency: dashboard.currency,
              color: AppColors.amber),
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('liabilities'),
          const SizedBox(height: AppSpacing.md),
          _BreakdownRow(
              label: 'Total Owed',
              amount: dashboard.totalLiabilities,
              currency: dashboard.currency,
              color: AppColors.red),
          const SizedBox(height: AppSpacing.screenV),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow(
      {required this.label,
      required this.amount,
      required this.currency,
      this.color});
  final String label;
  final double amount;
  final String currency;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  AppTypography.bodyMedium.copyWith(color: AppColors.inkDim)),
          AmountDisplay(
            amount: amount,
            currency: currency,
            style: AppTypography.monoSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ── Hero Dash Stat (hero card bottom row) ─────────────────────────────────

class _HeroDashStat extends StatelessWidget {
  const _HeroDashStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.monoSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          SectionLabel(label),
        ],
      ),
    );
  }
}

// ── Quick Action Tile ──────────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MudraCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.red, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Projection Block ──────────────────────────────────────────────────────

class _ProjectionBlock extends StatelessWidget {
  const _ProjectionBlock({
    required this.dashboard,
    required this.selectedDay,
    required this.today,
    required this.daysInMonth,
    required this.onDayChanged,
    required this.onReset,
  });

  final DashboardData dashboard;
  final int selectedDay;
  final int today;
  final int daysInMonth;
  final ValueChanged<int> onDayChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final projected = dashboard.monthRunway;
    final projectedColor = projected >= 0 ? AppColors.green : AppColors.red;
    final now = DateTime.now();
    final monthName = _monthShortNames[now.month - 1];
    final daysLeft = daysInMonth - today;

    return MudraCard.primary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('projected month end'),
              if (selectedDay != today)
                GestureDetector(
                  onTap: onReset,
                  child: Text(
                    'Reset to today',
                    style: AppTypography.monoXSmall
                        .copyWith(color: AppColors.inkDim),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          AmountDisplay(
            amount: projected,
            currency: dashboard.currency,
            style: AppTypography.displaySmall.copyWith(color: projectedColor),
            coloured: false,
          ),
          const SizedBox(height: 2),
          Text(
            '$daysLeft days remaining · $monthName ${now.year}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const SectionLabel('simulate day'),
              const Spacer(),
              Text(
                'Day $selectedDay',
                style: AppTypography.monoXSmall.copyWith(color: AppColors.red),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: projectedColor,
              inactiveTrackColor: AppColors.border,
              thumbColor: projectedColor,
              overlayColor: projectedColor.withAlpha(30),
            ),
            child: Slider(
              value: selectedDay.toDouble(),
              min: 1,
              max: daysInMonth.toDouble(),
              divisions: daysInMonth - 1,
              onChanged: (v) => onDayChanged(v.round()),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('liquid now'),
                    const SizedBox(height: 2),
                    AmountDisplay(
                      amount: dashboard.bankBalance,
                      currency: dashboard.currency,
                      style: AppTypography.monoSmall,
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: AppColors.border),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel('balance day $selectedDay'),
                    const SizedBox(height: 2),
                    AmountDisplay(
                      amount: dashboard.simulatedBalanceOnDay,
                      currency: dashboard.currency,
                      style: AppTypography.monoSmall
                          .copyWith(color: projectedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

