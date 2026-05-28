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
import '../../widgets/charts/asset_allocation_donut.dart';
import '../../widgets/common/amount_display.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/mudra_hero_card.dart';
import '../../widgets/common/section_label.dart';
import '../../widgets/common/quick_spend_sheet.dart';
import '../../widgets/fuel_gauge_ring.dart';

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
        color: AppColors.gold,
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
                    AppTypography.headingMedium.copyWith(color: AppColors.gold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline,
                      color: AppColors.inkDim),
                  onPressed: () => context.push('/profile'),
                ),
              ],
              bottom: TabBar(
                labelColor: AppColors.gold,
                unselectedLabelColor: AppColors.inkDim,
                labelStyle: AppTypography.labelMedium,
                unselectedLabelStyle: AppTypography.labelMedium,
                indicatorColor: AppColors.gold,
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
                                .copyWith(color: AppColors.gold),
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
                          foregroundColor: AppColors.gold,
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

              // ── Month Runway Hero ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH, AppSpacing.md,
                    AppSpacing.screenH, 0),
                child: MudraHeroCard(
                  label: 'MONTH RUNWAY',
                  amount: CurrencyFormatter.compact(
                      dashboard.monthRunway, dashboard.currency),
                  sublabel:
                      'of ${CurrencyFormatter.compact(dashboard.bankBalance, dashboard.currency)} liquid · Day $selectedDay',
                ),
              ),

              // ── Fuel Gauge ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.screenV),
                child: Column(
                  children: [
                    Center(
                      child: FuelGaugeRing(
                        percentage: dashboard.dayBalancePercent,
                        runway: dashboard.monthRunway,
                        currency: dashboard.currency,
                        arcColor: dashboard.gaugeColor,
                        isOvercommitted: dashboard.isOvercommitted,
                        selectedDay: selectedDay,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ── Day Slider ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      child: Row(
                        children: [
                          const SectionLabel('simulate day'),
                          const Spacer(),
                          Text(
                            'Day $selectedDay',
                            style: AppTypography.monoSmall
                                .copyWith(color: AppColors.gold),
                          ),
                          if (selectedDay != today) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => ref
                                  .read(selectedDayProvider.notifier)
                                  .state = today,
                              child: Text(
                                'Reset',
                                style: AppTypography.labelMedium
                                    .copyWith(color: AppColors.inkDim),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: dashboard.gaugeColor,
                        inactiveTrackColor: AppColors.border,
                        thumbColor: dashboard.gaugeColor,
                        overlayColor: dashboard.gaugeColor.withAlpha(40),
                      ),
                      child: Slider(
                        value: selectedDay.toDouble(),
                        min: 1,
                        max: daysInMonth.toDouble(),
                        divisions: daysInMonth - 1,
                        onChanged: (v) => ref
                            .read(selectedDayProvider.notifier)
                            .state = v.round(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── CURRENT LIQUID | SIMULATED DAY ───────────────────────
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SectionLabel("day's liquid"),
                                const SizedBox(height: 4),
                                AmountDisplay(
                                  amount: dashboard.bankBalance,
                                  currency: dashboard.currency,
                                  style: AppTypography.monoMedium,
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                              color: AppColors.border, thickness: 1, width: 32),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SectionLabel("day's balance"),
                                const SizedBox(height: 4),
                                AmountDisplay(
                                  amount: dashboard.simulatedBalanceOnDay,
                                  currency: dashboard.currency,
                                  style: AppTypography.monoMedium
                                      .copyWith(color: dashboard.gaugeColor),
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

              const Divider(color: AppColors.border),

              // ── Runway Table ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.screenV),
                child: _RunwayTable(
                    dashboard: dashboard, selectedDay: selectedDay),
              ),

              const Divider(color: AppColors.border),

              // ── Quick Stats ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    _StatTile(
                      label: 'NET WORTH',
                      onTap: () => context.go('/portfolio'),
                      child: AmountDisplay(
                        amount: dashboard.netWorth,
                        currency: dashboard.currency,
                        style: AppTypography.monoLarge,
                        coloured: true,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatTile(
                      label: 'FIXED ITEMS',
                      onTap: () => context.go('/debts'),
                      child: Text(
                        '${dashboard.fixedItemsCount}',
                        style: AppTypography.monoLarge
                            .copyWith(color: AppColors.ink),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatTile(
                      label: 'ACCOUNTS',
                      onTap: () => context.go('/accounts'),
                      child: Text(
                        '${dashboard.accountsCount}',
                        style: AppTypography.monoLarge
                            .copyWith(color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.border),

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
                        _QuickActionTile(
                          icon: Icons.account_tree_outlined,
                          label: 'App Map',
                          onTap: () => context.push('/map'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.border),

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
                                .copyWith(color: AppColors.gold),
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
        Positioned(
          right: AppSpacing.screenH,
          bottom: AppSpacing.md,
          child: FloatingActionButton(
            tooltip: 'Log spend',
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.white,
            onPressed: () => _openQuickSpendSheet(context, dashboard.currency),
            child: const Icon(Icons.add),
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

  String _debitLabel(int d) {
    if (d == 0) return 'Today';
    if (d == 1) return 'Tomorrow';
    return 'in $d days';
  }

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
                  _debitLabel(daysUntil),
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
                  ),
                  Container(width: 1, height: 28, color: Colors.white24),
                  _HeroDashStat(
                    label: 'INVESTED',
                    value: CurrencyFormatter.compact(
                        dashboard.investmentsTotal, dashboard.currency),
                  ),
                  Container(width: 1, height: 28, color: Colors.white24),
                  _HeroDashStat(
                    label: 'LIABILITIES',
                    value: CurrencyFormatter.compact(
                        dashboard.totalLiabilities, dashboard.currency),
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
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StatTile(
                label: 'ASSETS',
                onTap: () => context.go('/accounts'),
                child: AmountDisplay(
                  amount: dashboard.totalAssets,
                  currency: dashboard.currency,
                  style: AppTypography.monoLarge,
                  compact: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatTile(
                label: 'INVESTED',
                onTap: () => context.go('/portfolio'),
                child: AmountDisplay(
                  amount: dashboard.investmentsTotal,
                  currency: dashboard.currency,
                  style:
                      AppTypography.monoLarge.copyWith(color: AppColors.amber),
                  compact: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatTile(
                label: 'LIABILITIES',
                onTap: () => context.go('/portfolio'),
                child: AmountDisplay(
                  amount: dashboard.totalLiabilities,
                  currency: dashboard.currency,
                  style: AppTypography.monoLarge.copyWith(color: AppColors.red),
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.lg),
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

// ─── Shared Stat Tile ─────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.label, required this.child, required this.onTap});
  final String label;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          highlightColor: AppColors.goldLight.withAlpha(120),
          splashColor: AppColors.goldLight.withAlpha(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                const SizedBox(height: 4),
                SectionLabel(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero Dash Stat (hero card bottom row) ─────────────────────────────────

class _HeroDashStat extends StatelessWidget {
  const _HeroDashStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'IBM Plex Mono',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'IBM Plex Mono',
              fontSize: 8,
              letterSpacing: 1.0,
              color: Colors.white38,
            ),
          ),
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
      elevation: true,
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
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
