import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/account.dart';
import 'models/app_settings.dart';
import 'models/credit.dart';
import 'models/debt.dart';
import 'models/investment_platform.dart';
import 'models/outgoing.dart';

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
    directory: dir.path,
  );
}

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden in main');
});
