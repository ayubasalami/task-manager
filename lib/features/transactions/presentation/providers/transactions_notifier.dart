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

  Future<bool> updateTransaction(
    String id,
    Transaction updatedTransaction,
  ) async {
    final success = await _repository.updateTransaction(id, updatedTransaction);

    if (success) {
      state = state.map((t) {
        return t.id == id ? updatedTransaction.copyWith(id: id) : t;
      }).toList();
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
