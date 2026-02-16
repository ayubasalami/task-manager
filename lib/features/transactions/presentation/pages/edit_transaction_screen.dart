import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_sizes.dart';
import '../../../../core/colors.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_picker_bottom_sheet.dart';
import '../widgets/transaction_type_toggle.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final String transactionId;

  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  final _amountFocusNode = FocusNode();

  Transaction? _originalTransaction;
  TransactionCategory? _selectedCategory;
  DateTime? _selectedDate;
  bool _isExpense = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  void _loadTransaction() {
    final notifier = ref.read(transactionsNotifierProvider.notifier);
    _originalTransaction = notifier.getTransactionById(widget.transactionId);

    if (_originalTransaction != null) {
      final transaction = _originalTransaction!;

      _amountController = TextEditingController(
        text: transaction.absoluteAmount.toStringAsFixed(2),
      );
      _merchantController = TextEditingController(text: transaction.merchant);

      _selectedCategory = TransactionCategory.fromString(transaction.category);
      _selectedDate = transaction.date;
      _isExpense = transaction.isExpense;
    } else {
      _amountController = TextEditingController();
      _merchantController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryPickerBottomSheet(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedTransaction = Transaction(
        id: widget.transactionId,
        amount: _isExpense ? -amount : amount,
        merchant: _merchantController.text.trim(),
        category: _selectedCategory!.displayName,
        date: _selectedDate ?? DateTime.now(),
        status: TransactionStatus.completed,
      );
      final notifier = ref.read(transactionsNotifierProvider.notifier);
      final success = await notifier.updateTransaction(
        widget.transactionId,
        updatedTransaction,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update transaction'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges()) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes. Do you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  bool _hasChanges() {
    if (_originalTransaction == null) return false;

    final transaction = _originalTransaction!;
    return _amountController.text !=
            transaction.absoluteAmount.toStringAsFixed(2) ||
        _merchantController.text != transaction.merchant ||
        _selectedCategory?.displayName != transaction.category ||
        _selectedDate != transaction.date ||
        _isExpense != transaction.isExpense;
  }

  @override
  Widget build(BuildContext context) {
    if (_originalTransaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction Not Found')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy');

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  context.pop();
                }
              },
            ),
            title: const Text(
              'Edit Transaction',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount *',
                      hintText: '0.00',
                      prefixText: '₦ ',
                      helperText: 'Enter transaction amount',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Amount is required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid amount greater than 0';
                      }
                      if (amount > 999999.99) {
                        return 'Amount too large';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingLg),

                  TextFormField(
                    controller: _merchantController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Merchant Name *',
                      hintText: 'e.g., Starbucks, Whole Foods',
                      suffixIcon: Icon(Icons.store),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Merchant name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Enter at least 2 characters';
                      }
                      if (value.length > 50) {
                        return 'Merchant name too long';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingLg),

                  GestureDetector(
                    onTap: _showCategoryPicker,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          hintText: 'Select category',
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          prefixIcon: _selectedCategory != null
                              ? Icon(
                                  _selectedCategory!.icon,
                                  color: _selectedCategory!.color,
                                )
                              : const Icon(Icons.category),
                        ),
                        controller: TextEditingController(
                          text: _selectedCategory?.displayName ?? '',
                        ),
                        validator: (value) {
                          if (_selectedCategory == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingLg),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date *',
                          hintText: 'Select date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: dateFormat.format(
                            _selectedDate ?? DateTime.now(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingLg),
                  Text(
                    'Transaction Type',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSm),
                  TransactionTypeToggle(
                    isExpense: _isExpense,
                    onChanged: (isExpense) {
                      setState(() {
                        _isExpense = isExpense;
                      });
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingLg),

                  const SizedBox(height: AppSizes.paddingXl),

                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeightLg,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Update Transaction'),
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingXl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
