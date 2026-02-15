import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_sizes.dart';
import '../../../../core/colors.dart';
import '../../domain/entities/transaction_category.dart';
import '../providers/transaction_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  Future<void> _handleRefresh() async {
    await ref.read(refreshProvider.notifier).refresh();
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

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isRefreshing = ref.watch(refreshProvider);

    final categories = ['All', ...TransactionCategory.allCategories];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: TextField(
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
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
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

          Expanded(
            child: transactions.isEmpty
                ? EmptyTransactionsState(
                    message: _searchController.text.isNotEmpty
                        ? 'No transactions found'
                        : 'No transactions yet',
                    subtitle: _searchController.text.isNotEmpty
                        ? 'Try searching for a different merchant'
                        : 'Start by adding your first transaction',
                  )
                : RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        top: AppSizes.paddingSm,
                        bottom: 80, // Space for FAB
                      ),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return TransactionCard(
                          transaction: transaction,
                          onTap: () => _onTransactionTapped(transaction.id),
                        );
                      },
                    ),
                  ),
          ),
        ],
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
