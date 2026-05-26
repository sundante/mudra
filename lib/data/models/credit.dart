import 'package:isar/isar.dart';

part 'credit.g.dart';

@collection
class Credit {
  Id id = Isar.autoIncrement;

  late String uid;
  late String name;

  @enumerated
  late CreditCategory category;

  double amount = 0.0;
  int creditDate = 1;
  bool isActive = true;
  late DateTime createdAt;
}

enum CreditCategory { salary, interest, refund, cashback, dividend, other }

// Isar v3 bypasses Dart null safety at runtime — use these safe getters everywhere.
extension CreditSafe on Credit {
  String get safeUid => ((uid as dynamic) as String?) ?? '';
  double get safeAmount => ((amount as dynamic) as double?) ?? 0.0;
  int get safeCreditDate => ((creditDate as dynamic) as int?) ?? 0;
  String get safeName => ((name as dynamic) as String?) ?? '';
  bool get safeIsActive => ((isActive as dynamic) as bool?) ?? true;
  CreditCategory get safeCategory =>
      ((category as dynamic) as CreditCategory?) ?? CreditCategory.other;
}
