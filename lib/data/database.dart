import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/account.dart';
import 'models/app_settings.dart';
import 'models/credit.dart';
import 'models/debt.dart';
import 'models/investment_platform.dart';
import 'models/outgoing.dart';

const mudraDbName = 'mudra_db';

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

Future<Isar> openDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
      AccountSchema,
      OutgoingSchema,
      InvestmentPlatformSchema,
      DebtSchema,
      AppSettingsSchema,
      CreditSchema,
    ],
    name: mudraDbName,
    directory: dir.path,
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

  final debt = await isar.debts.where().findFirst();
  debt?.safeUid;
  debt?.safeCounterpartyName;
  debt?.safeDirection;

  final credit = await isar.credits.where().findFirst();
  credit?.safeUid;
  credit?.safeName;
  credit?.safeCategory;

  final settings = await isar.appSettings.get(1);
  settings?.safeBaseCurrency;
  settings?.safePayDate;
}

Future<void> resetDatabaseFiles() async {
  final instance = Isar.getInstance(mudraDbName);
  if (instance != null) {
    await instance.close(deleteFromDisk: true);
    return;
  }

  final dir = await getApplicationDocumentsDirectory();
  final dbDir = Directory(dir.path);
  if (!await dbDir.exists()) return;

  await for (final entity in dbDir.list()) {
    final name =
        entity.uri.pathSegments.isNotEmpty ? entity.uri.pathSegments.last : '';
    if (!name.startsWith(mudraDbName)) continue;

    if (entity is File) {
      await entity.delete();
    } else if (entity is Directory) {
      await entity.delete(recursive: true);
    }
  }
}

Future<void> clearAllData(Isar isar) async {
  await isar.writeTxn(() async {
    await isar.accounts.clear();
    await isar.outgoings.clear();
    await isar.investmentPlatforms.clear();
    await isar.debts.clear();
    await isar.credits.clear();
    await isar.appSettings.clear();
  });
}

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden in main');
});
