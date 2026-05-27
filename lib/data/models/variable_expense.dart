import 'package:isar/isar.dart';

part 'variable_expense.g.dart';

@collection
class VariableExpense {
  Id id = Isar.autoIncrement;

  late String uid;
  double amount = 0.0;

  @enumerated
  late VariableCategory category;

  String? note;
  late DateTime spentAt;
  late DateTime createdAt;
}

enum VariableCategory {
  food,
  transport,
  shopping,
  health,
  entertainment,
  misc,
}

extension VariableCategoryLabel on VariableCategory {
  String get label => switch (this) {
        VariableCategory.food => 'Food',
        VariableCategory.transport => 'Transport',
        VariableCategory.shopping => 'Shopping',
        VariableCategory.health => 'Health',
        VariableCategory.entertainment => 'Entertainment',
        VariableCategory.misc => 'Misc',
      };

  String get emoji => switch (this) {
        VariableCategory.food => '🍽',
        VariableCategory.transport => '🚗',
        VariableCategory.shopping => '🛍',
        VariableCategory.health => '💊',
        VariableCategory.entertainment => '🎬',
        VariableCategory.misc => '📦',
      };
}

extension VariableExpenseSafe on VariableExpense {
  String get safeUid => ((uid as dynamic) as String?) ?? '';
  double get safeAmount => ((amount as dynamic) as double?) ?? 0.0;
  VariableCategory get safeCategory =>
      ((category as dynamic) as VariableCategory?) ?? VariableCategory.misc;
  String get safeNote => ((note as dynamic) as String?) ?? '';
  DateTime get safeSpentAt =>
      ((spentAt as dynamic) as DateTime?) ??
      DateTime.fromMillisecondsSinceEpoch(0);
  DateTime get safeCreatedAt =>
      ((createdAt as dynamic) as DateTime?) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
