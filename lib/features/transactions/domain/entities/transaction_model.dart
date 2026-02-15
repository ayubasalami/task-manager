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
    return '$symbol\$${absoluteAmount.toStringAsFixed(2)}';
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
