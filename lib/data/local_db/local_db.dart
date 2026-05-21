import 'package:hive/hive.dart';

import '../models/expense.dart';
import '../models/sync_queue_action.dart';

class ExpenseLocalService {
  final Box expensesBox = Hive.box('expenses');
  final Box syncQueueBox = Hive.box('sync_queue');
  final Box remoteExpensesBox = Hive.box('remote_expenses');

  Future<void> saveExpense(Expense expense) async {
    await expensesBox.put(expense.id, expense.toMap());
  }

  List<Expense> getExpenses() {
    return expensesBox.values
        .map((e) => Expense.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Expense? getExpenseById(String id) {
    final data = expensesBox.get(id);
    if (data == null) {
      return null;
    }

    return Expense.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> deleteExpense(String id) async {
    await expensesBox.delete(id);
  }

  Future<void> saveRemoteExpense(Expense expense) async {
    await remoteExpensesBox.put(expense.id, expense.toMap());
  }

  Expense? getRemoteExpenseById(String id) {
    final data = remoteExpensesBox.get(id);
    if (data == null) {
      return null;
    }

    return Expense.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> deleteRemoteExpense(String id) async {
    await remoteExpensesBox.delete(id);
  }

  List<SyncQueueAction> getSyncQueue() {
    return syncQueueBox.values
        .map((e) => SyncQueueAction.fromMap(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  SyncQueueAction? getPendingQueueActionForExpense(String expenseId) {
    for (final action in getSyncQueue()) {
      if (action.expenseId == expenseId && action.status != 'done') {
        return action;
      }
    }

    return null;
  }

  Future<void> saveQueueAction(SyncQueueAction action) async {
    await syncQueueBox.put(action.id, action.toMap());
  }

  Future<void> deleteQueueAction(String id) async {
    await syncQueueBox.delete(id);
  }

  Future<void> clearQueueActionForExpense(String expenseId) async {
    final queuedAction = getPendingQueueActionForExpense(expenseId);
    if (queuedAction != null) {
      await deleteQueueAction(queuedAction.id);
    }
  }
}
