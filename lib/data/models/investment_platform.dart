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

extension InvestmentPlatformSafe on InvestmentPlatform {
  String get safeUid => ((uid as dynamic) as String?) ?? '';
  String get safePlatformName => ((platformName as dynamic) as String?) ?? '';
  AssetType get safeAssetType =>
      ((assetType as dynamic) as AssetType?) ?? AssetType.other;
  double get safeInvestedAmount =>
      ((investedAmount as dynamic) as double?) ?? 0.0;
  double get safeCurrentValue => ((currentValue as dynamic) as double?) ?? 0.0;
  bool get safeIsDeleted => ((isDeleted as dynamic) as bool?) ?? false;
}
