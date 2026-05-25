import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'models/account.dart';
import 'models/app_settings.dart';
import 'models/credit.dart';
import 'models/debt.dart';
import 'models/investment_platform.dart';
import 'models/outgoing.dart';

// Demo profile: Rohan, 30, Software Engineer, Bangalore. ₹1.2L/month take-home.
// Seeded only on fresh install (when accounts collection is empty).

const _uuid = Uuid();

Future<void> seedDemoData(Isar isar) async {
  await isar.writeTxn(() async {
    // ── App Settings ────────────────────────────────────────────────────────
    final settings = AppSettings()
      ..baseCurrency = 'INR'
      ..monthlyIncome = 120000
      ..payDate = 1;
    settings.id = 1;
    await isar.appSettings.put(settings);

    // ── Accounts ─────────────────────────────────────────────────────────────
    final hdfc = Account()
      ..uid = _uuid.v4()
      ..nickname = 'HDFC Savings'
      ..bankName = 'HDFC Bank'
      ..accountType = AccountType.personal
      ..isCreditCard = false
      ..balance = 85000
      ..fdAmount = 200000
      ..includeInLiquid = true
      ..balanceUpdatedAt = DateTime.now()
      ..sortOrder = 0
      ..isDeleted = false
      ..createdAt = DateTime.now();

    final jupiter = Account()
      ..uid = _uuid.v4()
      ..nickname = 'Jupiter'
      ..bankName = 'Federal Bank'
      ..accountType = AccountType.personal
      ..isCreditCard = false
      ..balance = 12400
      ..fdAmount = 0
      ..includeInLiquid = true
      ..balanceUpdatedAt = DateTime.now()
      ..sortOrder = 1
      ..isDeleted = false
      ..createdAt = DateTime.now();

    final hdfcCC = Account()
      ..uid = _uuid.v4()
      ..nickname = 'HDFC Credit Card'
      ..bankName = 'HDFC Bank'
      ..accountType = AccountType.personal
      ..isCreditCard = true
      ..balance = 18200
      ..fdAmount = 0
      ..includeInLiquid = false
      ..balanceUpdatedAt = DateTime.now()
      ..sortOrder = 2
      ..isDeleted = false
      ..createdAt = DateTime.now();

    await isar.accounts.putAll([hdfc, jupiter, hdfcCC]);

    // ── Outgoings — Expenses ─────────────────────────────────────────────────
    final homeLoan = Outgoing()
      ..uid = _uuid.v4()
      ..name = 'Home Loan EMI'
      ..outgoingType = OutgoingType.expense
      ..category = OutgoingCategory.loan
      ..amount = 18500
      ..debitDate = 5
      ..isActive = true
      ..createdAt = DateTime.now();

    final termLife = Outgoing()
      ..uid = _uuid.v4()
      ..name = 'LIC Term Life'
      ..outgoingType = OutgoingType.expense
      ..category = OutgoingCategory.insurance
      ..amount = 3200
      ..debitDate = 10
      ..isActive = true
      ..createdAt = DateTime.now();

    final healthIns = Outgoing()
      ..uid = _uuid.v4()
      ..name = 'Star Health Insurance'
      ..outgoingType = OutgoingType.expense
      ..category = OutgoingCategory.insurance
      ..amount = 2100
      ..debitDate = 15
      ..isActive = true
      ..createdAt = DateTime.now();

    final netflix = Outgoing()
      ..uid = _uuid.v4()
      ..name = 'Netflix'
      ..outgoingType = OutgoingType.expense
      ..category = OutgoingCategory.subscription
      ..amount = 649
      ..debitDate = 20
      ..isActive = true
      ..createdAt = DateTime.now();

    final spotify = Outgoing()
      ..uid = _uuid.v4()
      ..name = 'Spotify'
      ..outgoingType = OutgoingType.expense
      ..category = OutgoingCategory.subscription
      ..amount = 119
      ..debitDate = 22
      ..isActive = true
      ..createdAt = DateTime.now();

    // ── Outgoings — Investments ──────────────────────────────────────────────
    final nipponSip = Outgoing()
      ..uid = _uuid.v4()
      ..name = 'Nippon Small Cap SIP'
      ..outgoingType = OutgoingType.investment
      ..category = OutgoingCategory.sip
      ..amount = 5000
      ..debitDate = 7
      ..isActive = true
      ..createdAt = DateTime.now();

    final hdfcSip = Outgoing()
      ..uid = _uuid.v4()
      ..name = 'HDFC Flexi Cap SIP'
      ..outgoingType = OutgoingType.investment
      ..category = OutgoingCategory.sip
      ..amount = 3000
      ..debitDate = 7
      ..isActive = true
      ..createdAt = DateTime.now();

    final ppf = Outgoing()
      ..uid = _uuid.v4()
      ..name = 'PPF — HDFC'
      ..outgoingType = OutgoingType.investment
      ..category = OutgoingCategory.ppf
      ..amount = 2000
      ..debitDate = 1
      ..isActive = true
      ..createdAt = DateTime.now();

    await isar.outgoings
        .putAll([homeLoan, termLife, healthIns, netflix, spotify, nipponSip, hdfcSip, ppf]);

    // ── Investment Platforms ─────────────────────────────────────────────────
    final groww = InvestmentPlatform()
      ..uid = _uuid.v4()
      ..platformName = 'Groww'
      ..assetType = AssetType.mutualFund
      ..investedAmount = 120000
      ..currentValue = 142500
      ..valueUpdatedAt = DateTime.now()
      ..isDeleted = false
      ..createdAt = DateTime.now();

    final zerodha = InvestmentPlatform()
      ..uid = _uuid.v4()
      ..platformName = 'Zerodha'
      ..assetType = AssetType.indianStocks
      ..investedAmount = 45000
      ..currentValue = 51200
      ..valueUpdatedAt = DateTime.now()
      ..isDeleted = false
      ..createdAt = DateTime.now();

    final epfo = InvestmentPlatform()
      ..uid = _uuid.v4()
      ..platformName = 'EPFO'
      ..assetType = AssetType.epf
      ..investedAmount = 95000
      ..currentValue = 104800
      ..valueUpdatedAt = DateTime.now()
      ..isDeleted = false
      ..createdAt = DateTime.now();

    await isar.investmentPlatforms.putAll([groww, zerodha, epfo]);

    // ── Debts ────────────────────────────────────────────────────────────────
    final lentToArjun = Debt()
      ..uid = _uuid.v4()
      ..counterpartyName = 'Arjun'
      ..direction = DebtDirection.theyOwe
      ..amount = 5000
      ..notes = 'Lent for bike repair'
      ..isSettled = false
      ..createdAt = DateTime.now();

    final owesPriya = Debt()
      ..uid = _uuid.v4()
      ..counterpartyName = 'Priya'
      ..direction = DebtDirection.iOwe
      ..amount = 3200
      ..notes = 'Shared trip expenses'
      ..isSettled = false
      ..createdAt = DateTime.now();

    await isar.debts.putAll([lentToArjun, owesPriya]);

    // ── Credits ──────────────────────────────────────────────────────────────
    final salary = Credit()
      ..uid = _uuid.v4()
      ..name = 'Salary — Employer'
      ..category = CreditCategory.salary
      ..amount = 120000
      ..creditDate = 1
      ..isActive = true
      ..createdAt = DateTime.now();

    final interest = Credit()
      ..uid = _uuid.v4()
      ..name = 'HDFC Savings Interest'
      ..category = CreditCategory.interest
      ..amount = 412
      ..creditDate = 10
      ..isActive = true
      ..createdAt = DateTime.now();

    await isar.credits.putAll([salary, interest]);
  });
}
