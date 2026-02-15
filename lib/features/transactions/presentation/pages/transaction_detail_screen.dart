import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_sizes.dart';
import '../../../../core/colors.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_info_row.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(transactionRepositoryProvider);
    final transaction = repository.getTransactionById(transactionId);

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Not Found')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final category = TransactionCategory.fromString(transaction.category);
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'transaction_${transaction.id}',
              child: Container(
                margin: const EdgeInsets.only(
                  top: 100,
                  left: AppSizes.paddingLg,
                  right: AppSizes.paddingLg,
                  bottom: AppSizes.paddingMd,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLg,
                  vertical: AppSizes.paddingXl,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: transaction.isExpense
                        ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                        : [const Color(0xFF00D09E), const Color(0xFF00B887)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: transaction.isExpense
                          ? AppColors.expense.withOpacity(0.3)
                          : AppColors.income.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category.icon,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMd),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          transaction.formattedAmount,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSm),
                      Text(
                        transaction.merchant,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.category,
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.none,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLg,
                vertical: AppSizes.paddingSm,
              ),
              padding: const EdgeInsets.all(AppSizes.paddingLg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.grey200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLg),
                  DetailInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: dateFormat.format(transaction.date),
                  ),
                  DetailInfoRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: timeFormat.format(transaction.date),
                  ),
                  DetailInfoRow(
                    icon: Icons.check_circle,
                    label: 'Status',
                    value: transaction.status.displayName,
                    valueColor: _getStatusColor(transaction.status),
                  ),
                  DetailInfoRow(
                    icon: category.icon,
                    label: 'Category',
                    value: transaction.category,
                    valueColor: category.color,
                  ),
                  DetailInfoRow(
                    icon: transaction.isExpense
                        ? Icons.trending_down
                        : Icons.trending_up,
                    label: 'Transaction Type',
                    value: transaction.isExpense ? 'Expense' : 'Income',
                    valueColor: transaction.isExpense
                        ? AppColors.expense
                        : AppColors.income,
                  ),
                  DetailInfoRow(
                    icon: Icons.tag,
                    label: 'Transaction ID',
                    value: '#${transaction.id}',
                    valueStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit feature coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMd,
                        ),
                        side: BorderSide(color: AppColors.grey300),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMd),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDeleteDialog(context, ref, transactionId);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMd,
                        ),
                        side: BorderSide(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingLg),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.failed:
        return AppColors.error;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String transactionId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Deleting transaction...'),
                    ],
                  ),
                  duration: Duration(days: 365),
                ),
              );

              final repository = ref.read(transactionRepositoryProvider);
              final success = await repository.deleteTransaction(transactionId);

              if (!context.mounted) return;

              messenger.hideCurrentSnackBar();

              if (success) {
                await ref.read(refreshProvider.notifier).refresh();

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Transaction deleted successfully'),
                    backgroundColor: AppColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
                context.pop();
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete transaction'),
                    backgroundColor: AppColors.error,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
