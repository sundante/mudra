import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/account.dart';
import 'models/app_settings.dart';
import 'models/credit.dart';
import 'models/debt.dart';
import 'models/investment_holding.dart';
import 'models/investment_platform.dart';
import 'models/outgoing.dart';
import 'models/variable_expense.dart';
import 'seed_data.dart';

const mudraDbName = 'mudra_db';
const guestDatabaseName = 'mudra_guest';
const _userDbPrefix = 'mudra_user_';

class DatabaseBootstrapResult {
  const DatabaseBootstrapResult({
    required this.isar,
    required this.didRecover,
  });

  final Isar isar;
  final bool didRecover;
}

typedef IsarOpenFn = Future<Isar> Function();
typedef IsarValidateFn = Future<void> Function(Isar isar);
typedef IsarResetFn = Future<void> Function();

Future<DatabaseBootstrapResult> bootstrapDatabase({
  IsarOpenFn? open,
  IsarValidateFn? validate,
  IsarResetFn? reset,
}) async {
  final result = await bootstrapWithRecovery<Isar>(
    open: open ?? openDatabase,
    validate: validate ?? validateDatabase,
    reset: reset ?? resetDatabaseFiles,
  );

  return DatabaseBootstrapResult(
    isar: result.resource,
    didRecover: result.didRecover,
  );
}

class BootstrapResult<T> {
  const BootstrapResult({
    required this.resource,
    required this.didRecover,
  });

  final T resource;
  final bool didRecover;
}

Future<BootstrapResult<T>> bootstrapWithRecovery<T>({
  required Future<T> Function() open,
  required Future<void> Function(T resource) validate,
  required Future<void> Function() reset,
}) async {
  try {
    final isar = await open();
    await validate(isar);
    return BootstrapResult(resource: isar, didRecover: false);
  } catch (error, stackTrace) {
    debugPrint('Mudra DB recovery triggered: $error');
    debugPrintStack(stackTrace: stackTrace);
    await reset();

    final recoveredIsar = await open();
    await validate(recoveredIsar);
    return BootstrapResult(resource: recoveredIsar, didRecover: true);
  }
}

String userDatabaseName(String userId) {
  final safeId = userId.replaceAll(RegExp('[^A-Za-z0-9_]'), '_');
  return '$_userDbPrefix$safeId';
}

Future<Isar> openDatabase({String name = mudraDbName}) async {
  final dir = await getApplicationSupportDirectory();
  return Isar.open(
    [
      AccountSchema,
      OutgoingSchema,
      InvestmentPlatformSchema,
      InvestmentHoldingSchema,
      DebtSchema,
      AppSettingsSchema,
      CreditSchema,
      VariableExpenseSchema,
    ],
    name: name,
    directory: dir.path,
  );
}

Future<DatabaseBootstrapResult> openUserDatabase(String userId) {
  final name = userDatabaseName(userId);
  return bootstrapDatabase(
    open: () => openDatabase(name: name),
    validate: validateDatabase,
    reset: () => resetDatabaseFiles(name: name),
  );
}

Future<void> validateDatabase(Isar isar) async {
  final account = await isar.accounts.where().findFirst();
  account?.safeUid;
  account?.safeNickname;
  account?.safeAccountType;

  final outgoing = await isar.outgoings.where().findFirst();
  outgoing?.safeUid;
  outgoing?.safeName;
  outgoing?.safeType;

  final platform = await isar.investmentPlatforms.where().findFirst();
  platform?.safeUid;
  platform?.safePlatformName;
  platform?.safeAssetType;

  final holding = await isar.investmentHoldings.where().findFirst();
  holding?.safeUid;
  holding?.safeSchemeName;
  holding?.safeAssetType;

  final debt = await isar.debts.where().findFirst();
  debt?.safeUid;
  debt?.safeCounterpartyName;
  debt?.safeDirection;

  final credit = await isar.credits.where().findFirst();
  credit?.safeUid;
  credit?.safeName;
  credit?.safeCategory;

  final variableExpense = await isar.variableExpenses.where().findFirst();
  variableExpense?.safeUid;
  variableExpense?.safeCategory;
  variableExpense?.safeAmount;

  final settings = await isar.appSettings.get(1);
  settings?.safeBaseCurrency;
  settings?.safePayDate;
}

Future<void> resetDatabaseFiles({String name = mudraDbName}) async {
  final instance = Isar.getInstance(name);
  if (instance != null) {
    await instance.close(deleteFromDisk: true);
    return;
  }

  final dir = await getApplicationSupportDirectory();
  final dbDir = Directory(dir.path);
  if (!await dbDir.exists()) return;

  await for (final entity in dbDir.list()) {
    final entityName =
        entity.uri.pathSegments.isNotEmpty ? entity.uri.pathSegments.last : '';
    if (!entityName.startsWith(name)) continue;

    if (entity is File) {
      await entity.delete();
    } else if (entity is Directory) {
      await entity.delete(recursive: true);
    }
  }
}

Future<Isar> openGuestDatabase() async {
  final isar = await openDatabase(name: guestDatabaseName);
  final isEmpty = await isar.accounts.count() == 0;
  if (isEmpty) {
    await seedDemoData(isar);
  }
  return isar;
}

Future<bool> legacyDatabaseHasData() async {
  final legacy = await openDatabase();
  final hasData = await legacy.accounts.count() > 0 ||
      await legacy.outgoings.count() > 0 ||
      await legacy.investmentPlatforms.count() > 0 ||
      await legacy.debts.count() > 0 ||
      await legacy.credits.count() > 0 ||
      await legacy.variableExpenses.count() > 0;
  await legacy.close();
  return hasData;
}

Future<void> migrateLegacyDatabaseInto(Isar target) async {
  final legacy = await openDatabase();
  final accounts = await legacy.accounts.where().findAll();
  final outgoings = await legacy.outgoings.where().findAll();
  final platforms = await legacy.investmentPlatforms.where().findAll();
  final holdings = await legacy.investmentHoldings.where().findAll();
  final debts = await legacy.debts.where().findAll();
  final credits = await legacy.credits.where().findAll();
  final expenses = await legacy.variableExpenses.where().findAll();
  final settings = await legacy.appSettings.get(1);

  await target.writeTxn(() async {
    await target.accounts.putAll(accounts);
    await target.outgoings.putAll(outgoings);
    await target.investmentPlatforms.putAll(platforms);
    await target.investmentHoldings.putAll(holdings);
    await target.debts.putAll(debts);
    await target.credits.putAll(credits);
    await target.variableExpenses.putAll(expenses);
    if (settings != null) {
      await target.appSettings.put(settings);
    }
  });
  await legacy.close(deleteFromDisk: true);
}

Future<void> discardLegacyDatabase() async {
  final legacy = await openDatabase();
  await legacy.close(deleteFromDisk: true);
}

Future<void> clearAllData(Isar isar) async {
  await isar.writeTxn(() async {
    await isar.accounts.clear();
    await isar.outgoings.clear();
    await isar.investmentPlatforms.clear();
    await isar.investmentHoldings.clear();
    await isar.debts.clear();
    await isar.credits.clear();
    await isar.variableExpenses.clear();
    await isar.appSettings.clear();
  });
}

final activeDatabaseProvider = StateProvider<Isar?>((ref) => null);

final isarProvider = Provider<Isar>((ref) {
  final isar = ref.watch(activeDatabaseProvider);
  if (isar == null) {
    throw StateError('Financial data is unavailable before authentication.');
  }
  return isar;
});
