import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  @Index()
  late String uid;

  late String nickname;
  String? bankName;
  String? categoryLabel;

  @enumerated
  late AccountType accountType;

  bool isCreditCard = false;
  double balance = 0.0;
  double fdAmount = 0.0;
  bool includeInLiquid = true;
  DateTime? balanceUpdatedAt;
  int sortOrder = 0;
  bool isDeleted = false;
  late DateTime createdAt;
}

enum AccountType { personal, joint, business }

// Isar v3 bypasses Dart null safety at runtime — use these safe getters everywhere.
extension AccountSafe on Account {
  String get safeUid => ((uid as dynamic) as String?) ?? '';
  String get safeNickname => ((nickname as dynamic) as String?) ?? '';
  String get safeBankName => ((bankName as dynamic) as String?) ?? '';
  String get safeCategoryLabel => ((categoryLabel as dynamic) as String?) ?? '';
  AccountType get safeAccountType =>
      ((accountType as dynamic) as AccountType?) ?? AccountType.personal;
  bool get safeIsCreditCard => ((isCreditCard as dynamic) as bool?) ?? false;
  double get safeFdAmount => ((fdAmount as dynamic) as double?) ?? 0.0;
  double get safeBalance => ((balance as dynamic) as double?) ?? 0.0;
  bool get safeIncludeInLiquid =>
      ((includeInLiquid as dynamic) as bool?) ?? true;
  bool get safeIsDeleted => ((isDeleted as dynamic) as bool?) ?? false;
  int get safeSortOrder => ((sortOrder as dynamic) as int?) ?? 0;
  DateTime get safeCreatedAt =>
      ((createdAt as dynamic) as DateTime?) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
