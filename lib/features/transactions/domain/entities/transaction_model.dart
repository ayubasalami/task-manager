class Transaction {
  final String id;
  final double amount;
  final String merchant;
  final String category;
  final DateTime date;
  final TransactionStatus status;

  const Transaction({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.date,
    required this.status,
  });

  bool get isIncome => amount > 0;

  bool get isExpense => amount < 0;

  double get absoluteAmount => amount.abs();

  String get formattedAmount {
    final symbol = isIncome ? '+' : '-';
    return '$symbol₦${absoluteAmount.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'merchant': merchant,
      'category': category,
      'date': date.toIso8601String(),
      'status': status.name,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      merchant: json['merchant'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
    );
  }

  Transaction copyWith({
    String? id,
    double? amount,
    String? merchant,
    String? category,
    DateTime? date,
    TransactionStatus? status,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}

enum TransactionStatus {
  completed,
  pending,
  failed;

  String get displayName {
    switch (this) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }
}
