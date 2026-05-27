import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 1;
  String baseCurrency = 'INR';
  double monthlyIncome = 0.0;
  int payDate = 1;
  String userName = '';
}

extension AppSettingsSafe on AppSettings {
  String get safeBaseCurrency =>
      ((baseCurrency as dynamic) as String?) ?? 'INR';
  double get safeMonthlyIncome =>
      ((monthlyIncome as dynamic) as double?) ?? 0.0;
  int get safePayDate => ((payDate as dynamic) as int?) ?? 1;
  String get safeUserName => ((userName as dynamic) as String?) ?? '';
}
