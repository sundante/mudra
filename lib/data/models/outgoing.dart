import 'package:isar/isar.dart';

part 'outgoing.g.dart';

@collection
class Outgoing {
  Id id = Isar.autoIncrement;

  late String uid;
  late String name;

  @enumerated
  late OutgoingType outgoingType;

  @enumerated
  late OutgoingCategory category;

  double amount = 0.0;
  int debitDate = 1;
  bool isActive = true;
  late DateTime createdAt;
}

// Isar v3 bypasses Dart null safety at runtime — non-nullable primitive
// fields can return null for records written by an older schema version.
// Isar v3 bypasses Dart null safety at runtime — non-nullable primitive
// fields can return null for records written by an older schema version.
extension OutgoingSafe on Outgoing {
  String get safeUid => ((uid as dynamic) as String?) ?? '';
  double get safeAmount => ((amount as dynamic) as double?) ?? 0.0;
  int get safeDebitDate => ((debitDate as dynamic) as int?) ?? 0;
  String get safeName => ((name as dynamic) as String?) ?? '';
  bool get safeIsActive => ((isActive as dynamic) as bool?) ?? true;
  DateTime get safeCreatedAt =>
      ((createdAt as dynamic) as DateTime?) ?? DateTime.now();
  OutgoingType get safeType =>
      ((outgoingType as dynamic) as OutgoingType?) ?? OutgoingType.expense;
  OutgoingCategory get safeCategory =>
      ((category as dynamic) as OutgoingCategory?) ?? OutgoingCategory.other;
}

enum OutgoingType { expense, investment }

enum OutgoingCategory {
  loan,
  insurance,
  utility,
  subscription,
  sip,
  ppf,
  epf,
  nps,
  other,
}
