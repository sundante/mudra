import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/account.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/debt.dart';
import '../../data/models/outgoing.dart';
import '../../providers/account_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/investment_provider.dart';
import '../../providers/outgoing_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/amount_display.dart';
import '../../widgets/common/section_label.dart';
import '../../widgets/platform_card.dart';

class NetScreen extends ConsumerWidget {
  const NetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardNotifierProvider);
    final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
    final platforms = ref.watch(platformsStreamProvider).valueOrNull ?? [];
    final debts = ref.watch(debtsStreamProvider).valueOrNull ?? [];
    final outgoings = ref.watch(outgoingsStreamProvider).valueOrNull ?? [];
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currency = settings?.safeBaseCurrency ?? 'INR';

    final liquidAccounts = accounts
        .where((a) =>
            !a.safeIsCreditCard &&
            a.safeAccountType == AccountType.personal &&
            a.safeIncludeInLiquid)
        .toList();
    final fdAccounts =
        accounts.where((a) => a.safeFdAmount > 0).toList();
    final ccAccounts =
        accounts.where((a) => a.safeIsCreditCard).toList();
    final activeDebtsIOwe = debts
        .where((d) => d.safeDirection == DebtDirection.iOwe && !d.safeIsSettled)
        .toList();
    final activeDebtsOwedToMe = debts
        .where((d) =>
            d.safeDirection == DebtDirection.theyOwe && !d.safeIsSettled)
        .toList();

    final now = DateTime.now();
    final emiOutgoings = outgoings
        .where((o) => o.safeIsActive && o.safeDebitDate <= now.day)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            pinned: true,
            title: Text(
              'Net Worth',
              style:
                  AppTypography.headingMedium.copyWith(color: AppColors.gold),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.screenV,
                AppSpacing.screenH,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Net Worth Hero ──────────────────────────────────
                  _NetWorthHero(
                    netWorth: dashboard.netWorth,
                    currency: currency,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Formula Row ─────────────────────────────────────
                  _FormulaCard(
                    assets: dashboard.totalAssets,
                    liabilities: dashboard.totalLiabilities,
                    currency: currency,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Money in Banks ──────────────────────────────────
                  _ExpandableSection(
                    label: 'MONEY IN BANKS',
                    total: dashboard.bankBalance + dashboard.fdTotal,
                    currency: currency,
                    color: AppColors.green,
                    children: [
                      if (liquidAccounts.isNotEmpty) ...[
                        const _SubLabel('Liquid Accounts'),
                        ...liquidAccounts.map((a) => _AccountRow(
                              name: a.safeNickname,
                              subtitle: a.safeBankName,
                              amount: a.safeBalance,
                              currency: currency,
                              color: AppColors.green,
                            )),
                      ],
                      if (fdAccounts.isNotEmpty) ...[
                        const _SubLabel('Fixed Deposits'),
                        ...fdAccounts.map((a) => _AccountRow(
                              name: a.safeNickname,
                              subtitle: 'FD',
                              amount: a.safeFdAmount,
                              currency: currency,
                              color: AppColors.green,
                            )),
                      ],
                      if (liquidAccounts.isEmpty && fdAccounts.isEmpty)
                        const _EmptyHint('No accounts added yet'),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Investments ─────────────────────────────────────
                  _ExpandableSection(
                    label: 'INVESTMENTS',
                    total: dashboard.investmentsTotal,
                    currency: currency,
                    color: AppColors.amber,
                    children: platforms.isEmpty
                        ? [const _EmptyHint('No investment platforms added')]
                        : platforms
                            .map((p) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.sm),
                                  child: PlatformCard(
                                    platform: p,
                                    currency: currency,
                                    onTap: () {},
                                  ),
                                ))
                            .toList(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── CC Outstanding ──────────────────────────────────
                  _ExpandableSection(
                    label: 'CC OUTSTANDING',
                    total: dashboard.ccOutstanding,
                    currency: currency,
                    color: AppColors.red,
                    children: ccAccounts.isEmpty
                        ? [const _EmptyHint('No credit cards added')]
                        : ccAccounts
                            .map((a) => _AccountRow(
                                  name: a.safeNickname,
                                  subtitle: a.safeBankName,
                                  amount: a.safeBalance,
                                  currency: currency,
                                  color: AppColors.red,
                                ))
                            .toList(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Loans & I Owe ───────────────────────────────────
                  _ExpandableSection(
                    label: 'LOANS & I OWE',
                    total: dashboard.debtsIOwe,
                    currency: currency,
                    color: AppColors.red,
                    children: [
                      if (activeDebtsIOwe.isNotEmpty) ...[
                        const _SubLabel('Personal'),
                        ...activeDebtsIOwe.map((d) => _AccountRow(
                              name: d.safeCounterpartyName,
                              subtitle:
                                  d.dueDate != null ? 'Due ${_formatDate(d.dueDate!)}' : '',
                              amount: d.safeAmount,
                              currency: currency,
                              color: AppColors.red,
                            )),
                      ],
                      if (emiOutgoings.isNotEmpty) ...[
                        const _SubLabel('Committed this month'),
                        ...emiOutgoings.take(5).map((o) => _AccountRow(
                              name: o.safeName,
                              subtitle: 'Day ${o.safeDebitDate}',
                              amount: o.safeAmount,
                              currency: currency,
                              color: AppColors.red,
                            )),
                      ],
                      if (activeDebtsIOwe.isEmpty && emiOutgoings.isEmpty)
                        const _EmptyHint('No outstanding debts'),
                    ],
                  ),

                  if (activeDebtsOwedToMe.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ExpandableSection(
                      label: 'OWED TO ME',
                      total: activeDebtsOwedToMe.fold(
                          0.0, (s, d) => s + d.safeAmount),
                      currency: currency,
                      color: AppColors.green,
                      children: activeDebtsOwedToMe
                          .map((d) => _AccountRow(
                                name: d.safeCounterpartyName,
                                subtitle: d.dueDate != null
                                    ? 'Due ${_formatDate(d.dueDate!)}'
                                    : '',
                                amount: d.safeAmount,
                                currency: currency,
                                color: AppColors.green,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

// ── Net Worth Hero ─────────────────────────────────────────────────────────

class _NetWorthHero extends StatelessWidget {
  const _NetWorthHero({required this.netWorth, required this.currency});

  final double netWorth;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isPositive = netWorth >= 0;
    return Column(
      children: [
        Text(
          'Your Net Worth',
          style: AppTypography.labelMedium.copyWith(color: AppColors.inkDim),
        ),
        const SizedBox(height: AppSpacing.sm),
        AmountDisplay(
          amount: netWorth,
          currency: currency,
          style: AppTypography.displayLarge.copyWith(
            color: isPositive ? AppColors.green : AppColors.red,
            fontSize: 44,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isPositive ? 'You\'re in the green' : 'Liabilities exceed assets',
          style: AppTypography.bodySmall.copyWith(
            color: isPositive ? AppColors.green : AppColors.red,
          ),
        ),
      ],
    );
  }
}

// ── Formula Card ───────────────────────────────────────────────────────────

class _FormulaCard extends StatelessWidget {
  const _FormulaCard({
    required this.assets,
    required this.liabilities,
    required this.currency,
  });

  final double assets;
  final double liabilities;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('Assets',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.inkDim)),
                const SizedBox(height: AppSpacing.xs),
                AmountDisplay(
                    amount: assets,
                    currency: currency,
                    style: AppTypography.monoMedium
                        .copyWith(color: AppColors.green)),
              ],
            ),
          ),
          Text('−',
              style:
                  AppTypography.bodyLarge.copyWith(color: AppColors.inkDim)),
          Expanded(
            child: Column(
              children: [
                Text('Liabilities',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.inkDim)),
                const SizedBox(height: AppSpacing.xs),
                AmountDisplay(
                    amount: liabilities,
                    currency: currency,
                    style: AppTypography.monoMedium
                        .copyWith(color: AppColors.red)),
              ],
            ),
          ),
          Text('=',
              style:
                  AppTypography.bodyLarge.copyWith(color: AppColors.inkDim)),
          Expanded(
            child: Column(
              children: [
                Text('Net Worth',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.inkDim)),
                const SizedBox(height: AppSpacing.xs),
                AmountDisplay(
                    amount: assets - liabilities,
                    currency: currency,
                    style: AppTypography.monoMedium.copyWith(
                        color: assets >= liabilities
                            ? AppColors.green
                            : AppColors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Expandable Section ─────────────────────────────────────────────────────

class _ExpandableSection extends StatelessWidget {
  const _ExpandableSection({
    required this.label,
    required this.total,
    required this.currency,
    required this.color,
    required this.children,
  });

  final String label;
  final double total;
  final String currency;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        title: SectionLabel(label),
        trailing: AmountDisplay(
          amount: total,
          currency: currency,
          style: AppTypography.monoMedium.copyWith(color: color),
        ),
        children: children,
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.name,
    required this.subtitle,
    required this.amount,
    required this.currency,
    required this.color,
  });

  final String name;
  final String subtitle;
  final double amount;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.ink)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.inkDim)),
              ],
            ),
          ),
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

class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(color: AppColors.inkDim),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
      ),
    );
  }
}
