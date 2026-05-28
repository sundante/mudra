import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/database.dart';
import '../data/models/account.dart';
import '../data/models/app_settings.dart';
import '../data/models/outgoing.dart';
import '../providers/auth_provider.dart';

const _uuid = Uuid();

class SetupWizardNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> complete({
    double? monthlyIncome,
    String? accountNickname,
    AccountType? accountType,
    double? accountBalance,
    String? expenseName,
    double? expenseAmount,
    int? expenseDayOfMonth,
  }) async {
    final isar = ref.read(activeDatabaseProvider)!;

    await isar.writeTxn(() async {
      final settings = await isar.appSettings.get(1) ?? AppSettings();
      if (monthlyIncome != null && monthlyIncome > 0) {
        settings.monthlyIncome = monthlyIncome;
      }
      settings.hasCompletedSetup = true;
      await isar.appSettings.put(settings);

      if (accountNickname != null && accountNickname.isNotEmpty) {
        final account = Account()
          ..uid = _uuid.v4()
          ..nickname = accountNickname
          ..bankName = accountNickname
          ..accountType = accountType ?? AccountType.personal
          ..balance = accountBalance ?? 0
          ..createdAt = DateTime.now();
        await isar.accounts.put(account);
      }

      if (expenseName != null && expenseName.isNotEmpty) {
        final outgoing = Outgoing()
          ..uid = _uuid.v4()
          ..name = expenseName
          ..amount = expenseAmount ?? 0
          ..debitDate = expenseDayOfMonth ?? 1
          ..outgoingType = OutgoingType.expense
          ..category = OutgoingCategory.other
          ..createdAt = DateTime.now();
        await isar.outgoings.put(outgoing);
      }
    });

    unawaited(ref.read(appSessionControllerProvider).completeSetup());
  }
}

final setupWizardProvider =
    NotifierProvider<SetupWizardNotifier, void>(SetupWizardNotifier.new);
