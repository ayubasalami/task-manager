import 'package:expense_tracker/features/transactions/presentation/providers/transactions_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repository/transaction_repository.dart';
import '../../domain/entities/transaction_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsNotifierProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);
      return TransactionsNotifier(repository);
    });

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final allTransactions = ref.watch(transactionsNotifierProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  var transactions = allTransactions;

  if (selectedCategory.toLowerCase() != 'all') {
    transactions = transactions.where((t) {
      return t.category.toLowerCase() == selectedCategory.toLowerCase();
    }).toList();
  }

  if (searchQuery.isNotEmpty) {
    transactions = transactions.where((t) {
      return t.merchant.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  return transactions;
});
