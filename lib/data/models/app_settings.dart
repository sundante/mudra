import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 1;
  String baseCurrency = 'INR';
  double monthlyIncome = 0.0;
  int payDate = 1;
}
