class Expense {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final bool isSynced;
  final String syncStatus;
  final DateTime lastModifiedAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.isSynced = false,
    this.syncStatus = 'pending',
    DateTime? lastModifiedAt,
  }) : lastModifiedAt = lastModifiedAt ?? date;

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? currency,
    String? category,
    DateTime? date,
    bool? isSynced,
    String? syncStatus,
    DateTime? lastModifiedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      isSynced: isSynced ?? this.isSynced,
      syncStatus: syncStatus ?? this.syncStatus,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date.toIso8601String(),
      'isSynced': isSynced,
      'syncStatus': syncStatus,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      currency: map['currency'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      isSynced: map['isSynced'] ?? false,
      syncStatus: map['syncStatus'] ??
          ((map['isSynced'] ?? false) ? 'synced' : 'pending'),
      lastModifiedAt: map['lastModifiedAt'] != null
          ? DateTime.parse(map['lastModifiedAt'])
          : DateTime.parse(map['date']),
    );
  }

  @override
  String toString() {
    return 'Expense(title: $title, amount: $amount, currency: $currency)';
  }
}
