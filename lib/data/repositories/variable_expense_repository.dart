import 'package:isar/isar.dart';

import '../models/variable_expense.dart';

class VariableExpenseRepository {
  VariableExpenseRepository(this._isar);

  final Isar _isar;

  Stream<List<VariableExpense>> watchLast6Months() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 5);
    final end = DateTime(now.year, now.month + 1);
    return _isar.variableExpenses
        .filter()
        .spentAtBetween(start, end, includeLower: true, includeUpper: false)
        .sortBySpentAtDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<VariableExpense>> watchCurrentMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month);
    final end = DateTime(now.year, now.month + 1);
    return _isar.variableExpenses
        .filter()
        .spentAtBetween(start, end, includeLower: true, includeUpper: false)
        .sortBySpentAtDesc()
        .watch(fireImmediately: true);
  }

  Future<void> save(VariableExpense expense) async {
    await _isar.writeTxn(() => _isar.variableExpenses.put(expense));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.variableExpenses.delete(id));
  }

  static double sumUpToDay(List<VariableExpense> expenses, int day) {
    return expenses
        .where((expense) => expense.safeSpentAt.day <= day)
        .fold(0.0, (sum, expense) => sum + expense.safeAmount);
  }

  static int countUpToDay(List<VariableExpense> expenses, int day) {
    return expenses.where((expense) => expense.safeSpentAt.day <= day).length;
  }
}
