import 'package:isar/isar.dart';

import 'investment_platform.dart';

part 'investment_holding.g.dart';

@collection
class InvestmentHolding {
  Id id = Isar.autoIncrement;

  late String uid;
  late int platformId;
  late String schemeName;

  @enumerated
  late AssetType assetType;

  double investedAmount = 0.0;
  double currentValue = 0.0;
  double units = 0.0;
  late DateTime createdAt;
}

extension InvestmentHoldingSafe on InvestmentHolding {
  String get safeUid => ((uid as dynamic) as String?) ?? '';
  int get safePlatformId => ((platformId as dynamic) as int?) ?? 0;
  String get safeSchemeName => ((schemeName as dynamic) as String?) ?? '';
  AssetType get safeAssetType =>
      ((assetType as dynamic) as AssetType?) ?? AssetType.other;
  double get safeInvestedAmount =>
      ((investedAmount as dynamic) as double?) ?? 0.0;
  double get safeCurrentValue => ((currentValue as dynamic) as double?) ?? 0.0;
  double get safeUnits => ((units as dynamic) as double?) ?? 0.0;
  DateTime get safeCreatedAt =>
      ((createdAt as dynamic) as DateTime?) ?? DateTime.now();
}
