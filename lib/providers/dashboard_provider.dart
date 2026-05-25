import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/utils/date_helpers.dart';
import '../data/models/account.dart';
import '../data/models/app_settings.dart';
import '../data/models/credit.dart';
import '../data/models/debt.dart';
import '../data/models/investment_platform.dart';
import '../data/models/outgoing.dart';
import 'account_provider.dart';
import 'credit_provider.dart';
import 'investment_provider.dart';
import 'outgoing_provider.dart';
import 'selected_day_provider.dart';
import 'settings_provider.dart';

part 'dashboard_provider.g.dart';

enum RunwayState { comfortable, watchOut, tight }

// ─── Value objects — plain typed data, never raw Isar objects ─────────────

class AccountRow {
  const AccountRow({required this.nickname, required this.balance});
  final String nickname;
  final double balance;
}

class CreditRow {
  const CreditRow({
    required this.name,
    required this.category,
    required this.amount,
    required this.isPending,
    required this.creditDate,
  });
  final String name;
  final CreditCategory category;
  final double amount;
  final bool isPending;
  final int creditDate;
}

class OutgoingRow {
  const OutgoingRow({
    required this.name,
    required this.amount,
    required this.type,
    required this.debitDate,
  });
  final String name;
  final double amount;
  final OutgoingType type;
  final int debitDate;
}

class CategoryGroup {
  const CategoryGroup({
    required this.category,
    required this.total,
    required this.items,
  });
  final OutgoingCategory category;
  final double total;
  final List<OutgoingRow> items;
}

// ─── DashboardData ────────────────────────────────────────────────────────

class DashboardData {
  const DashboardData({
    required this.bankBalance,
    required this.ccOutstanding,
    required this.futureCommitted,
    required this.monthRunway,
    required this.runwayPercent,
    required this.selectedDay,
    required this.creditsTotal,
    required this.receivedCredits,
    required this.pendingCredits,
    required this.alreadyFired,
    required this.firedGroups,
    required this.futureRows,
    required this.liquidRows,
    required this.fdTotal,
    required this.investmentsTotal,
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.fixedItemsCount,
    required this.accountsCount,
    required this.debitRadar,
    required this.currency,
  });

  // Formula components
  final double bankBalance;
  final double ccOutstanding;
  final double futureCommitted;
  final double monthRunway;
  final double runwayPercent;
  final int selectedDay;

  // Credits (pre-typed rows, no raw Isar objects)
  final double creditsTotal;
  final List<CreditRow> receivedCredits;
  final List<CreditRow> pendingCredits;

  // Debits fired as of selectedDay
  final double alreadyFired;
  final List<CategoryGroup> firedGroups;

  // Commitments after selectedDay
  final List<OutgoingRow> futureRows;

  // Cash in accounts
  final List<AccountRow> liquidRows;

  // Overall tab
  final double fdTotal;
  final double investmentsTotal;
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final int fixedItemsCount;
  final int accountsCount;
  final List<({OutgoingRow outgoing, int daysUntil})> debitRadar;
  final String currency;

  // Computed state
  RunwayState get gaugeState {
    if (runwayPercent > 60) return RunwayState.comfortable;
    if (runwayPercent >= 30) return RunwayState.watchOut;
    return RunwayState.tight;
  }

  Color get gaugeColor {
    switch (gaugeState) {
      case RunwayState.comfortable:
        return const Color(0xFF2A6B4F);
      case RunwayState.watchOut:
        return const Color(0xFFA05A10);
      case RunwayState.tight:
        return const Color(0xFFA83226);
    }
  }

  bool get isOvercommitted => monthRunway < 0;

  static const empty = DashboardData(
    bankBalance: 0,
    ccOutstanding: 0,
    futureCommitted: 0,
    monthRunway: 0,
    runwayPercent: 0,
    selectedDay: 1,
    creditsTotal: 0,
    receivedCredits: [],
    pendingCredits: [],
    alreadyFired: 0,
    firedGroups: [],
    futureRows: [],
    liquidRows: [],
    fdTotal: 0,
    investmentsTotal: 0,
    netWorth: 0,
    totalAssets: 0,
    totalLiabilities: 0,
    fixedItemsCount: 0,
    accountsCount: 0,
    debitRadar: [],
    currency: 'INR',
  );
}

// ─── Provider ─────────────────────────────────────────────────────────────

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  DashboardData build() {
    final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
    final outgoings = ref.watch(outgoingsStreamProvider).valueOrNull ?? [];
    final platforms = ref.watch(platformsStreamProvider).valueOrNull ?? [];
    final debts = ref.watch(debtsStreamProvider).valueOrNull ?? [];
    final credits = ref.watch(creditsStreamProvider).valueOrNull ?? [];
    final settings = ref.watch(settingsProvider).valueOrNull ?? AppSettings();
    final selectedDay = ref.watch(selectedDayProvider);

    return _compute(
        accounts, outgoings, platforms, debts, credits, settings, selectedDay);
  }

  DashboardData _compute(
    List<Account> accounts,
    List<Outgoing> outgoings,
    List<InvestmentPlatform> platforms,
    List<Debt> debts,
    List<Credit> credits,
    AppSettings settings,
    int selectedDay,
  ) {
    // Isar v3 safe helpers — cast to dynamic first to avoid static analysis
    // warnings on non-nullable fields that can be null at runtime.
    double safeDouble(dynamic v) => (v as double?) ?? 0.0;
    int safeInt(dynamic v) => (v as int?) ?? 0;

    // ── Cash in Accounts ────────────────────────────────────────────────
    final liquidAccounts = accounts.where((a) =>
        a.accountType == AccountType.personal &&
        !a.isCreditCard &&
        a.includeInLiquid);

    final bankBalance =
        liquidAccounts.fold(0.0, (s, a) => s + a.safeBalance);

    final liquidRows = liquidAccounts
        .map((a) =>
            AccountRow(nickname: a.safeNickname, balance: a.safeBalance))
        .toList();

    final fdTotal =
        accounts.fold(0.0, (s, a) => s + a.safeFdAmount);

    // ── CC Outstanding ──────────────────────────────────────────────────
    final ccOutstanding = accounts
        .where((a) => a.isCreditCard)
        .fold(0.0, (s, a) => s + a.safeBalance);

    // ── Credits split by selectedDay ────────────────────────────────────
    final receivedCredits = credits
        .where((c) => c.isActive && c.safeCreditDate <= selectedDay)
        .map((c) => CreditRow(
              name: c.safeName,
              category: c.safeCategory,
              amount: c.safeAmount,
              isPending: false,
              creditDate: c.safeCreditDate,
            ))
        .toList();

    final pendingCredits = credits
        .where((c) => c.isActive && c.safeCreditDate > selectedDay)
        .map((c) => CreditRow(
              name: c.safeName,
              category: c.safeCategory,
              amount: c.safeAmount,
              isPending: true,
              creditDate: c.safeCreditDate,
            ))
        .toList();

    final creditsTotal =
        receivedCredits.fold(0.0, (s, c) => s + c.amount);

    // ── Outgoings split by selectedDay ──────────────────────────────────
    final firedOutgoings = outgoings
        .where((o) => o.isActive && o.safeDebitDate <= selectedDay)
        .toList();

    final futureOutgoings = outgoings
        .where((o) => o.isActive && o.safeDebitDate > selectedDay)
        .toList()
      ..sort((a, b) => a.safeDebitDate.compareTo(b.safeDebitDate));

    final alreadyFired =
        firedOutgoings.fold(0.0, (s, o) => s + o.safeAmount);
    final futureCommitted =
        futureOutgoings.fold(0.0, (s, o) => s + o.safeAmount);

    // Group fired outgoings by category (pre-typed rows, no raw Isar)
    final groupMap = <OutgoingCategory, List<OutgoingRow>>{};
    for (final o in firedOutgoings) {
      groupMap.putIfAbsent(o.safeCategory, () => []).add(OutgoingRow(
        name: o.safeName,
        amount: o.safeAmount,
        type: o.safeType,
        debitDate: o.safeDebitDate,
      ));
    }
    final firedGroups = groupMap.entries
        .map((e) => CategoryGroup(
              category: e.key,
              total: e.value.fold(0.0, (s, r) => s + r.amount),
              items: e.value,
            ))
        .toList();

    final futureRows = futureOutgoings
        .map((o) => OutgoingRow(
              name: o.safeName,
              amount: o.safeAmount,
              type: o.safeType,
              debitDate: o.safeDebitDate,
            ))
        .toList();

    // ── Core Formula ────────────────────────────────────────────────────
    final monthRunway = bankBalance - ccOutstanding - futureCommitted;
    final runwayPercent = bankBalance > 0
        ? (monthRunway / bankBalance * 100).clamp(0.0, 100.0)
        : 0.0;

    // ── Overall / Net Worth ─────────────────────────────────────────────
    final investmentsTotal =
        platforms.fold(0.0, (s, p) => s + safeDouble(p.currentValue));
    final totalAssets = bankBalance + fdTotal + investmentsTotal;

    final personalDebts = debts
        .where((d) => d.direction == DebtDirection.iOwe && !d.isSettled)
        .fold(0.0, (s, d) => s + safeDouble(d.amount));
    final totalLiabilities = ccOutstanding + personalDebts;
    final netWorth = totalAssets - totalLiabilities;

    // ── Debit Radar (until end of month, real-time — not shifted by selectedDay)
    final daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    final daysUntilEndOfMonth = daysInMonth - DateTime.now().day;
    final radar = outgoings
        .where((o) => o.isActive)
        .map((o) => (
              outgoing: OutgoingRow(
                name: o.safeName,
                amount: o.safeAmount,
                type: o.safeType,
                debitDate: o.safeDebitDate,
              ),
              daysUntil: DateHelpers.daysUntilDebit(safeInt(o.debitDate)),
            ))
        .where((item) => item.daysUntil <= daysUntilEndOfMonth)
        .toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

    return DashboardData(
      bankBalance: bankBalance,
      ccOutstanding: ccOutstanding,
      futureCommitted: futureCommitted,
      monthRunway: monthRunway,
      runwayPercent: runwayPercent,
      selectedDay: selectedDay,
      creditsTotal: creditsTotal,
      receivedCredits: receivedCredits,
      pendingCredits: pendingCredits,
      alreadyFired: alreadyFired,
      firedGroups: firedGroups,
      futureRows: futureRows,
      liquidRows: liquidRows,
      fdTotal: fdTotal,
      investmentsTotal: investmentsTotal,
      netWorth: netWorth,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      fixedItemsCount: outgoings.where((o) => o.isActive).length,
      accountsCount: accounts.where((a) => !a.isDeleted).length,
      debitRadar: radar,
      currency: ((settings.baseCurrency as dynamic) as String?) ?? 'INR',
    );
  }
}
