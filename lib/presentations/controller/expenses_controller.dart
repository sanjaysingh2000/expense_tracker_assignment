import 'dart:async';

import 'package:assignment_01/data/remote_data_source/connectivity_service.dart';
import 'package:assignment_01/data/models/sync_queue_action.dart';
import 'package:assignment_01/data/remote_data_source/currency_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../data/local_db/local_db.dart';
import '../../data/models/expense.dart';

class ExpenseController extends GetxController {
  final db = ExpenseLocalService();
  final currencyService = CurrencyService();
  final connectivityService = ConnectivityService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  var expenses = <Expense>[].obs;
  var pendingQueue = <SyncQueueAction>[].obs;

  var totalInINR = 0.0.obs;
  var isCalculatingTotal = false.obs;
  var isSyncing = false.obs;
  var isOnline = false.obs;
  var lastSyncMessage = 'Offline mode active. Changes are stored locally.'.obs;

  int get pendingActionCount =>
      pendingQueue.where((action) => action.status == 'pending').length;

  int get conflictCount =>
      pendingQueue.where((action) => action.status == 'conflict').length;

  @override
  void onInit() {
    super.onInit();
    refreshState();
    _watchConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  void refreshState() {
    loadExpenses();
    loadQueue();
  }

  void loadExpenses() {
    final storedExpenses = db.getExpenses()
      ..sort((a, b) => b.date.compareTo(a.date));
    expenses.value = storedExpenses;
  }

  void loadQueue() {
    pendingQueue.value = db.getSyncQueue();
  }

  Future<void> addExpense(Expense expense) async {
    final now = DateTime.now();
    final localExpense = expense.copyWith(
      isSynced: false,
      syncStatus: 'pending',
      lastModifiedAt: now,
    );

    await db.saveExpense(localExpense);
    await _upsertQueueAction(
      expenseId: localExpense.id,
      actionType: 'create',
      payload: localExpense.toMap(),
    );

    refreshState();
    lastSyncMessage.value = 'Expense saved offline and queued for sync.';
  }

  Future<void> updateExpense(Expense expense) async {
    final now = DateTime.now();
    final localExpense = expense.copyWith(
      isSynced: false,
      syncStatus: 'pending',
      lastModifiedAt: now,
    );

    await db.saveExpense(localExpense);
    await _upsertQueueAction(
      expenseId: localExpense.id,
      actionType: 'update',
      payload: localExpense.toMap(),
    );

    refreshState();
    lastSyncMessage.value =
        'Update stored locally and added to the sync queue.';
  }

  Future<void> deleteExpense(String id) async {
    final existingExpense = db.getExpenseById(id);
    if (existingExpense == null) {
      return;
    }

    await db.deleteExpense(id);
    await _upsertQueueAction(
      expenseId: id,
      actionType: 'delete',
      payload: existingExpense
          .copyWith(
            syncStatus: 'deleted',
            lastModifiedAt: DateTime.now(),
          )
          .toMap(),
    );

    refreshState();
    lastSyncMessage.value = 'Delete stored locally and queued for sync.';
  }

  Future<void> syncPendingActions() async {
    if (isSyncing.value) {
      return;
    }

    final online = await connectivityService.hasInternetConnection();
    isOnline.value = online;

    if (!online) {
      lastSyncMessage.value =
          'No internet connection. Pending changes will sync when back online.';
      return;
    }

    isSyncing.value = true;
    lastSyncMessage.value = 'Syncing queued actions...';

    try {
      final actions = List<SyncQueueAction>.from(pendingQueue);
      var syncedCount = 0;
      var conflictsFound = 0;

      for (final action in actions) {
        if (action.status != 'pending') {
          continue;
        }

        final didSync = await _processQueueAction(action);
        if (didSync) {
          syncedCount++;
        } else {
          conflictsFound++;
        }
      }

      refreshState();

      if (conflictsFound > 0) {
        lastSyncMessage.value =
            'Sync finished with $conflictsFound conflict${conflictsFound == 1 ? '' : 's'}.';
      } else if (syncedCount > 0) {
        lastSyncMessage.value =
            'Sync complete. $syncedCount action${syncedCount == 1 ? '' : 's'} processed.';
      } else {
        lastSyncMessage.value = 'Everything is already in sync.';
      }
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> resolveConflictWithLocal(String expenseId) async {
    final queueAction = pendingQueue.firstWhereOrNull(
      (action) => action.expenseId == expenseId && action.status == 'conflict',
    );

    if (queueAction == null || queueAction.payload == null) {
      return;
    }

    final localExpense = Expense.fromMap(queueAction.payload!).copyWith(
      isSynced: false,
      syncStatus: 'pending',
      lastModifiedAt: DateTime.now(),
    );

    await db.saveExpense(localExpense);
    await db.saveQueueAction(
      queueAction.copyWith(
        status: 'pending',
        conflictMessage: null,
        payload: localExpense.toMap(),
        createdAt: DateTime.now(),
      ),
    );

    refreshState();
    lastSyncMessage.value =
        'Conflict marked to keep local changes on next sync.';
  }

  Future<void> resolveConflictWithRemote(String expenseId) async {
    final queueAction = pendingQueue.firstWhereOrNull(
      (action) => action.expenseId == expenseId && action.status == 'conflict',
    );

    if (queueAction == null) {
      return;
    }

    final remoteExpense = db.getRemoteExpenseById(expenseId);

    if (remoteExpense != null) {
      await db.saveExpense(
        remoteExpense.copyWith(
          isSynced: true,
          syncStatus: 'synced',
        ),
      );
    } else {
      await db.deleteExpense(expenseId);
    }

    await db.deleteQueueAction(queueAction.id);

    refreshState();
    lastSyncMessage.value = 'Conflict resolved using remote version.';
  }

  Future<void> calculateTotal() async {
    isCalculatingTotal.value = true;
    double total = 0;

    try {
      for (final expense in expenses) {
        if (expense.currency == 'INR') {
          total += expense.amount;
        } else {
          final converted = await currencyService.convert(
            from: expense.currency,
            to: 'INR',
            amount: expense.amount,
          );
          total += converted;
        }
      }

      totalInINR.value = total;
    } finally {
      isCalculatingTotal.value = false;
    }
  }

  Future<void> _upsertQueueAction({
    required String expenseId,
    required String actionType,
    required Map<String, dynamic> payload,
  }) async {
    final existingAction = db.getPendingQueueActionForExpense(expenseId);
    final now = DateTime.now();

    if (existingAction == null) {
      await db.saveQueueAction(
        SyncQueueAction(
          id: '${expenseId}_$actionType',
          expenseId: expenseId,
          actionType: actionType,
          status: 'pending',
          createdAt: now,
          payload: payload,
        ),
      );
      return;
    }

    if (existingAction.actionType == 'create' && actionType == 'update') {
      await db.saveQueueAction(
        existingAction.copyWith(
          payload: payload,
          createdAt: now,
          status: 'pending',
          conflictMessage: null,
        ),
      );
      return;
    }

    if (existingAction.actionType == 'create' && actionType == 'delete') {
      await db.deleteQueueAction(existingAction.id);
      return;
    }

    await db.saveQueueAction(
      existingAction.copyWith(
        actionType: actionType,
        payload: payload,
        createdAt: now,
        status: 'pending',
        conflictMessage: null,
      ),
    );
  }

  Future<bool> _processQueueAction(SyncQueueAction action) async {
    switch (action.actionType) {
      case 'create':
      case 'update':
        return _syncUpsertAction(action);
      case 'delete':
        return _syncDeleteAction(action);
      default:
        return true;
    }
  }

  Future<bool> _syncUpsertAction(SyncQueueAction action) async {
    if (action.payload == null) {
      await db.deleteQueueAction(action.id);
      return true;
    }

    final localExpense = Expense.fromMap(action.payload!);
    final remoteExpense = db.getRemoteExpenseById(action.expenseId);

    if (_hasRemoteConflict(
      localModifiedAt: localExpense.lastModifiedAt,
      remoteExpense: remoteExpense,
    )) {
      await _markConflict(
        action: action,
        expense: localExpense.copyWith(syncStatus: 'conflict'),
        message: 'Remote version is newer than your local change.',
      );
      return false;
    }

    final syncedExpense = localExpense.copyWith(
      isSynced: true,
      syncStatus: 'synced',
    );

    await db.saveRemoteExpense(syncedExpense);
    await db.saveExpense(syncedExpense);
    await db.deleteQueueAction(action.id);
    return true;
  }

  Future<bool> _syncDeleteAction(SyncQueueAction action) async {
    final remoteExpense = db.getRemoteExpenseById(action.expenseId);
    final deletedSnapshot =
        action.payload != null ? Expense.fromMap(action.payload!) : null;

    if (remoteExpense != null &&
        deletedSnapshot != null &&
        remoteExpense.lastModifiedAt.isAfter(deletedSnapshot.lastModifiedAt)) {
      await _markConflict(
        action: action,
        expense: deletedSnapshot.copyWith(syncStatus: 'conflict'),
        message: 'Remote version changed after this item was deleted locally.',
      );
      return false;
    }

    await db.deleteRemoteExpense(action.expenseId);
    await db.deleteQueueAction(action.id);
    return true;
  }

  bool _hasRemoteConflict({
    required DateTime localModifiedAt,
    required Expense? remoteExpense,
  }) {
    return remoteExpense != null &&
        remoteExpense.lastModifiedAt.isAfter(localModifiedAt);
  }

  Future<void> _markConflict({
    required SyncQueueAction action,
    required Expense expense,
    required String message,
  }) async {
    await db.saveExpense(
      expense.copyWith(
        isSynced: false,
        syncStatus: 'conflict',
      ),
    );
    await db.saveQueueAction(
      action.copyWith(
        status: 'conflict',
        conflictMessage: message,
      ),
    );
  }

  Future<void> _watchConnectivity() async {
    await _refreshInternetStatus();

    _connectivitySubscription =
        connectivityService.onConnectivityChanged.listen(
      (_) async {
        await _refreshInternetStatus();
      },
    );
  }

  Future<void> _refreshInternetStatus() async {
    final online = await connectivityService.hasInternetConnection();
    final wasOnline = isOnline.value;

    isOnline.value = online;

    if (!online) {
      lastSyncMessage.value =
          'Offline mode active. Changes are stored locally.';
      return;
    }

    if (!wasOnline && pendingActionCount > 0) {
      lastSyncMessage.value =
          'Back online. $pendingActionCount pending action${pendingActionCount == 1 ? '' : 's'} ready to sync.';
    } else if (!wasOnline) {
      lastSyncMessage.value = 'Back online. Everything is ready to sync.';
    }
  }
}
