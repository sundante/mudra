import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  @Index()
  late String uid;

  late String nickname;
  String? bankName;

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
