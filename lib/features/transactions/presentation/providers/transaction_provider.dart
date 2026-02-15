import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repository/transaction_repository.dart';
import '../../domain/entities/transaction_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsProvider = Provider<List<Transaction>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getTransactions();
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return repository.getFilteredTransactions(
    category: selectedCategory,
    searchQuery: searchQuery,
  );
});

class RefreshNotifier extends StateNotifier<bool> {
  RefreshNotifier() : super(false);

  Future<void> refresh() async {
    state = true;
    await Future.delayed(const Duration(seconds: 1));
    state = false;
  }
}

final refreshProvider = StateNotifierProvider<RefreshNotifier, bool>((ref) {
  return RefreshNotifier();
});
