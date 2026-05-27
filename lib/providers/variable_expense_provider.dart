import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/models/variable_expense.dart';
import '../data/repositories/variable_expense_repository.dart';

final variableExpenseRepoProvider = Provider<VariableExpenseRepository>(
  (ref) => VariableExpenseRepository(ref.watch(isarProvider)),
);

final variableExpensesProvider = StreamProvider<List<VariableExpense>>(
  (ref) => ref.watch(variableExpenseRepoProvider).watchCurrentMonth(),
);

final todaySpendProvider = Provider<double>((ref) {
  final expenses = ref.watch(variableExpensesProvider).valueOrNull ?? [];
  final today = DateTime.now().day;
  return VariableExpenseRepository.sumUpToDay(expenses, today);
});
