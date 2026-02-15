import 'dart:convert';

import '../../../../core/utils/app_storage.dart';
import '../../domain/entities/transaction_model.dart';

class TransactionRepository {
  static const String _transactionsKey = 'transactions_list';

  List<Transaction>? _cachedTransactions;

  List<Transaction> getTransactions() {
    if (_cachedTransactions != null) {
      return _cachedTransactions!;
    }

    final stored = AppStorage.getString(_transactionsKey);
    if (stored != null && stored.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(stored);
        _cachedTransactions = jsonList
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();
        return _cachedTransactions!;
      } catch (e) {
        _cachedTransactions = _mockTransactions;
        return _cachedTransactions!;
      }
    }

    _cachedTransactions = List.from(_mockTransactions);
    _saveTransactions();
    return _cachedTransactions!;
  }

  void invalidateCache() {
    _cachedTransactions = null;
  }

  Transaction? getTransactionById(String id) {
    try {
      return getTransactions().firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final transactions = List<Transaction>.from(getTransactions());
      transactions.insert(0, transaction);

      _cachedTransactions = transactions;

      final saved = await _saveTransactions();
      if (!saved) return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final transactions = List<Transaction>.from(getTransactions());
      final index = transactions.indexWhere((t) => t.id == id);

      if (index == -1) return false;

      transactions.removeAt(index);
      _cachedTransactions = transactions;

      final saved = await _saveTransactions();
      if (!saved) return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  double getCurrentBalance() {
    final transactions = getTransactions();
    if (transactions.isEmpty) return 0.0;

    return transactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  double getTotalIncome() {
    final transactions = getTransactions();
    return transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenses() {
    final transactions = getTransactions();
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.absoluteAmount);
  }

  List<Transaction> searchByMerchant(String query) {
    if (query.isEmpty) return getTransactions();

    return getTransactions().where((transaction) {
      return transaction.merchant.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Transaction> filterByCategory(String category) {
    if (category.toLowerCase() == 'all') return getTransactions();

    return getTransactions().where((transaction) {
      return transaction.category.toLowerCase() == category.toLowerCase();
    }).toList();
  }

  List<Transaction> getFilteredTransactions({
    String? category,
    String? searchQuery,
  }) {
    var transactions = getTransactions();

    if (category != null && category.toLowerCase() != 'all') {
      transactions = transactions.where((t) {
        return t.category.toLowerCase() == category.toLowerCase();
      }).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      transactions = transactions.where((t) {
        return t.merchant.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return transactions;
  }

  Future<bool> _saveTransactions() async {
    if (_cachedTransactions == null) return true;

    try {
      final jsonList = _cachedTransactions!
          .map((transaction) => transaction.toJson())
          .toList();
      final jsonString = jsonEncode(jsonList);
      final success = await AppStorage.setString(_transactionsKey, jsonString);
      return success;
    } catch (e) {
      print('Error saving transactions: $e');
      return false;
    }
  }

  Future<void> clearTransactions() async {
    _cachedTransactions = null;
    await AppStorage.remove(_transactionsKey);
  }
}

final List<Transaction> _mockTransactions = [
  Transaction(
    id: '1',
    amount: -45.50,
    merchant: 'Whole Foods',
    category: 'Groceries',
    date: DateTime(2024, 2, 10),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '2',
    amount: -120.00,
    merchant: 'Shell Gas Station',
    category: 'Transportation',
    date: DateTime(2024, 2, 9),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '3',
    amount: -32.00,
    merchant: 'Pizza Hut',
    category: 'Dining',
    date: DateTime(2024, 2, 8),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '4',
    amount: -89.99,
    merchant: 'Amazon',
    category: 'Shopping',
    date: DateTime(2024, 2, 7),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '5',
    amount: -25.00,
    merchant: 'Netflix',
    category: 'Entertainment',
    date: DateTime(2024, 2, 6),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '6',
    amount: -150.00,
    merchant: 'CVS Pharmacy',
    category: 'Healthcare',
    date: DateTime(2024, 2, 5),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '7',
    amount: -75.50,
    merchant: 'Electric Company',
    category: 'Utilities',
    date: DateTime(2024, 2, 4),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '8',
    amount: -28.99,
    merchant: 'Trader Joes',
    category: 'Groceries',
    date: DateTime(2024, 2, 3),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '9',
    amount: -55.00,
    merchant: 'Uber',
    category: 'Transportation',
    date: DateTime(2024, 2, 2),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '10',
    amount: -42.50,
    merchant: 'Chipotle',
    category: 'Dining',
    date: DateTime(2024, 2, 1),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '11',
    amount: -19.99,
    merchant: 'Spotify',
    category: 'Entertainment',
    date: DateTime(2024, 1, 31),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '12',
    amount: -125.00,
    merchant: 'Target',
    category: 'Shopping',
    date: DateTime(2024, 1, 30),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '13',
    amount: -65.00,
    merchant: 'Safeway',
    category: 'Groceries',
    date: DateTime(2024, 1, 29),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '14',
    amount: -85.00,
    merchant: 'Lyft',
    category: 'Transportation',
    date: DateTime(2024, 1, 28),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '15',
    amount: -38.75,
    merchant: 'Starbucks',
    category: 'Dining',
    date: DateTime(2024, 1, 27),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '16',
    amount: -200.00,
    merchant: 'Doctor Visit',
    category: 'Healthcare',
    date: DateTime(2024, 1, 26),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '17',
    amount: -45.00,
    merchant: 'Water Bill',
    category: 'Utilities',
    date: DateTime(2024, 1, 25),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '18',
    amount: -99.99,
    merchant: 'Best Buy',
    category: 'Shopping',
    date: DateTime(2024, 1, 24),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '19',
    amount: -15.99,
    merchant: 'AMC Theaters',
    category: 'Entertainment',
    date: DateTime(2024, 1, 23),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '20',
    amount: -52.30,
    merchant: 'Costco',
    category: 'Groceries',
    date: DateTime(2024, 1, 22),
    status: TransactionStatus.completed,
  ),
  Transaction(
    id: '21',
    amount: 10000,
    merchant: 'Salary',
    category: 'other',
    date: DateTime(2024, 1, 23),
    status: TransactionStatus.completed,
  ),
];
