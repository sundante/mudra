import 'package:isar/isar.dart';

part 'debt.g.dart';

@collection
class Debt {
  Id id = Isar.autoIncrement;

  late String uid;
  late String counterpartyName;

  @enumerated
  late DebtDirection direction;

  double amount = 0.0;
  DateTime? dueDate;
  String? notes;
  bool isSettled = false;
  late DateTime createdAt;
}

enum DebtDirection { iOwe, theyOwe }
