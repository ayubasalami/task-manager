import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_sizes.dart';
import '../../../../core/colors.dart';
import '../../domain/entities/transaction_category.dart';
import '../providers/transaction_provider.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/category_filter_chip.dart';
import '../widgets/empty_transactions_widget.dart';
import '../widgets/transaction_card.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  Future<void> _handleRefresh() async {
    final notifier = ref.read(transactionsNotifierProvider.notifier);
    notifier.refresh();
    await Future.delayed(const Duration(seconds: 1));
  }

  void _onCategorySelected(String category) {
    ref.read(selectedCategoryProvider.notifier).state = category;
  }

  void _onTransactionTapped(String transactionId) {
    context.push('/home/transaction/$transactionId');
  }

  void _onAddTransactionTapped() {
    context.push('/home/add');
  }

  Future<void> _handleDelete(String transactionId) async {
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Deleting transaction...'),
          ],
        ),
        duration: Duration(days: 365),
      ),
    );

    final notifier = ref.read(transactionsNotifierProvider.notifier);
    final success = await notifier.deleteTransaction(transactionId);

    if (!mounted) return;

    messenger.hideCurrentSnackBar();

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to delete transaction'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final allTransactions = ref.watch(transactionsNotifierProvider);

    final currentBalance = allTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );

    final totalIncome = allTransactions
        .where((t) => t.amount > 0)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = allTransactions
        .where((t) => t.amount < 0)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    final categories = ['All', ...TransactionCategory.allCategories];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Container(),
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  _focusNode.unfocus();
                },
                child: Column(
                  children: [
                    BalanceCard(
                      currentBalance: currentBalance,
                      totalIncome: totalIncome,
                      totalExpenses: totalExpenses,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMd),
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by merchant...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            borderSide: BorderSide(color: AppColors.grey300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            borderSide: BorderSide(color: AppColors.grey300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMd,
                            vertical: AppSizes.paddingMd,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMd,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryFilterChip(
                            label: category,
                            isSelected: selectedCategory == category,
                            onTap: () => _onCategorySelected(category),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingSm),
                  ],
                ),
              ),
            ),
            transactions.isEmpty
                ? SliverFillRemaining(
                    child: EmptyTransactionsState(
                      message: _searchController.text.isNotEmpty
                          ? 'No transactions found'
                          : 'No transactions yet',
                      subtitle: _searchController.text.isNotEmpty
                          ? 'Try searching for a different merchant'
                          : 'Start by adding your first transaction',
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.only(
                      top: AppSizes.paddingSm,
                      bottom: 80, // Space for FAB
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final transaction = transactions[index];
                        return TransactionCard(
                          transaction: transaction,
                          onTap: () => _onTransactionTapped(transaction.id),
                          onDelete: _handleDelete,
                        );
                      }, childCount: transactions.length),
                    ),
                  ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddTransactionTapped,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}
