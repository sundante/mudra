import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/utils/date_helpers.dart';
import '../data/models/account.dart';
import '../data/models/app_settings.dart';
import '../data/models/debt.dart';
import '../data/models/investment_platform.dart';
import '../data/models/outgoing.dart';
import 'account_provider.dart';
import 'investment_provider.dart';
import 'outgoing_provider.dart';
import 'settings_provider.dart';

part 'dashboard_provider.g.dart';

class DashboardData {
  final double liquidTotal;
  final double fdTotal;
  final double fixedCommitted;
  final double balanceForMonth;
  final double balancePercent;
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final List<({Outgoing outgoing, int daysUntil})> debitRadar;
  final String currency;

  const DashboardData({
    required this.liquidTotal,
    required this.fdTotal,
    required this.fixedCommitted,
    required this.balanceForMonth,
    required this.balancePercent,
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.debitRadar,
    required this.currency,
  });

  static const empty = DashboardData(
    liquidTotal: 0,
    fdTotal: 0,
    fixedCommitted: 0,
    balanceForMonth: 0,
    balancePercent: 0,
    netWorth: 0,
    totalAssets: 0,
    totalLiabilities: 0,
    debitRadar: [],
    currency: 'INR',
  );
}

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  DashboardData build() {
    final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
    final outgoings = ref.watch(outgoingsStreamProvider).valueOrNull ?? [];
    final platforms = ref.watch(platformsStreamProvider).valueOrNull ?? [];
    final debts = ref.watch(debtsStreamProvider).valueOrNull ?? [];
    final settings =
        ref.watch(settingsProvider).valueOrNull ?? AppSettings();

    return _compute(accounts, outgoings, platforms, debts, settings);
  }

  DashboardData _compute(
    List<Account> accounts,
    List<Outgoing> outgoings,
    List<InvestmentPlatform> platforms,
    List<Debt> debts,
    AppSettings settings,
  ) {
    final today = DateTime.now().day;

    final liquidAccounts = accounts.where((a) =>
        a.accountType == AccountType.personal &&
        !a.isCreditCard &&
        a.includeInLiquid);

    final liquidTotal =
        liquidAccounts.fold(0.0, (sum, a) => sum + a.balance);
    final fdTotal = accounts.fold(0.0, (sum, a) => sum + a.fdAmount);

    final fixedCommitted = outgoings
        .where((o) => o.isActive && o.debitDate >= today)
        .fold(0.0, (sum, o) => sum + o.amount);

    final balanceForMonth = liquidTotal - fixedCommitted;
    final balancePercent = liquidTotal > 0
        ? (balanceForMonth / liquidTotal * 100).clamp(0.0, 100.0)
        : 0.0;

    final ccOutstanding = accounts
        .where((a) => a.isCreditCard)
        .fold(0.0, (sum, a) => sum + a.balance);

    final investmentsTotal =
        platforms.fold(0.0, (sum, p) => sum + p.currentValue);
    final totalAssets = liquidTotal + fdTotal + investmentsTotal;

    final personalDebts = debts
        .where((d) => d.direction == DebtDirection.iOwe && !d.isSettled)
        .fold(0.0, (sum, d) => sum + d.amount);
    final totalLiabilities = ccOutstanding + personalDebts;

    final netWorth = totalAssets - totalLiabilities;

    final radar = outgoings
        .where((o) => o.isActive)
        .map((o) =>
            (outgoing: o, daysUntil: DateHelpers.daysUntilDebit(o.debitDate)))
        .where((item) => item.daysUntil <= 7)
        .toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    return DashboardData(
      liquidTotal: liquidTotal,
      fdTotal: fdTotal,
      fixedCommitted: fixedCommitted,
      balanceForMonth: balanceForMonth,
      balancePercent: balancePercent,
      netWorth: netWorth,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      debitRadar: radar,
      currency: settings.baseCurrency,
    );
  }
}
