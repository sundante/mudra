import 'package:isar/isar.dart';

part 'investment_platform.g.dart';

@collection
class InvestmentPlatform {
  Id id = Isar.autoIncrement;

  late String uid;
  late String platformName;

  @enumerated
  late AssetType assetType;

  double investedAmount = 0.0;
  double currentValue = 0.0;
  DateTime? valueUpdatedAt;
  bool isDeleted = false;
  late DateTime createdAt;
}

enum AssetType {
  indianStocks,
  usStocks,
  mutualFund,
  ppf,
  epf,
  nps,
  gold,
  other,
}
