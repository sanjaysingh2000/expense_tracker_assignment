class SyncQueueAction {
  final String id;
  final String expenseId;
  final String actionType;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;
  final String? conflictMessage;

  SyncQueueAction({
    required this.id,
    required this.expenseId,
    required this.actionType,
    required this.status,
    required this.createdAt,
    this.payload,
    this.conflictMessage,
  });

  SyncQueueAction copyWith({
    String? id,
    String? expenseId,
    String? actionType,
    String? status,
    DateTime? createdAt,
    Map<String, dynamic>? payload,
    String? conflictMessage,
  }) {
    return SyncQueueAction(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      actionType: actionType ?? this.actionType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      payload: payload ?? this.payload,
      conflictMessage: conflictMessage ?? this.conflictMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expenseId': expenseId,
      'actionType': actionType,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'payload': payload,
      'conflictMessage': conflictMessage,
    };
  }

  factory SyncQueueAction.fromMap(Map<String, dynamic> map) {
    return SyncQueueAction(
      id: map['id'],
      expenseId: map['expenseId'],
      actionType: map['actionType'],
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      payload: map['payload'] != null
          ? Map<String, dynamic>.from(map['payload'])
          : null,
      conflictMessage: map['conflictMessage'],
    );
  }
}
