import 'package:flutter_riverpod/legacy.dart';

import '../../data/repository/transaction_repository.dart';
import '../../domain/entities/transaction_model.dart';

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final TransactionRepository _repository;

  TransactionsNotifier(this._repository) : super([]) {
    _loadTransactions();
  }

  void _loadTransactions() {
    state = _repository.getTransactions();
  }

  Future<bool> addTransaction(Transaction transaction) async {
    final success = await _repository.addTransaction(transaction);
    if (success) {
      _loadTransactions();
    }
    return success;
  }

  Future<bool> deleteTransaction(String id) async {
    final success = await _repository.deleteTransaction(id);
    if (success) {
      _loadTransactions();
    }
    return success;
  }

  void refresh() {
    _loadTransactions();
  }
}
