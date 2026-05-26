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

extension DebtSafe on Debt {
  String get safeUid => ((uid as dynamic) as String?) ?? '';
  String get safeCounterpartyName =>
      ((counterpartyName as dynamic) as String?) ?? '';
  DebtDirection get safeDirection =>
      ((direction as dynamic) as DebtDirection?) ?? DebtDirection.iOwe;
  double get safeAmount => ((amount as dynamic) as double?) ?? 0.0;
  String get safeNotes => ((notes as dynamic) as String?) ?? '';
  bool get safeIsSettled => ((isSettled as dynamic) as bool?) ?? false;
}
