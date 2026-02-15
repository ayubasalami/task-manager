import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_sizes.dart';
import '../../../../core/colors.dart';
import '../providers/add_transaction_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/category_picker_bottom_sheet.dart';
import '../widgets/transaction_type_toggle.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    final currentCategory = ref.read(addTransactionFormProvider).category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryPickerBottomSheet(
        selectedCategory: currentCategory,
        onCategorySelected: (category) {
          ref.read(addTransactionFormProvider.notifier).setCategory(category);
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final currentDate = ref.read(addTransactionFormProvider).selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
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

    if (picked != null && picked != currentDate) {
      ref.read(addTransactionFormProvider.notifier).setDate(picked);
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

    ref.read(addTransactionFormProvider.notifier).setAmount(amount);
    ref
        .read(addTransactionFormProvider.notifier)
        .setMerchant(_merchantController.text.trim());
    ref
        .read(addTransactionFormProvider.notifier)
        .setNotes(
          _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

    final success = await ref
        .read(addTransactionFormProvider.notifier)
        .submitTransaction();

    if (!mounted) return;

    if (success) {
      await ref.read(refreshProvider.notifier).refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction added successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      context.pop();
    } else {
      if (!success) {
        final error = ref.read(addTransactionFormProvider).error;
        final shouldRetry = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Failed to Save'),
            content: Text(error ?? 'Could not save transaction...'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );

        if (shouldRetry == true) {
          _submitForm();
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_amountController.text.isNotEmpty ||
        _merchantController.text.isNotEmpty ||
        _notesController.text.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(addTransactionFormProvider);
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
              'Add Transaction',
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
                      prefixText: '\$ ',
                      suffixIcon: Icon(Icons.attach_money),
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
                          prefixIcon: formState.category != null
                              ? Icon(
                                  formState.category!.icon,
                                  color: formState.category!.color,
                                )
                              : const Icon(Icons.category),
                        ),
                        controller: TextEditingController(
                          text: formState.category?.displayName ?? '',
                        ),
                        validator: (value) {
                          if (formState.category == null) {
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
                          text: dateFormat.format(formState.selectedDate),
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
                    isExpense: formState.isExpense,
                    onChanged: (isExpense) {
                      ref
                          .read(addTransactionFormProvider.notifier)
                          .setIsExpense(isExpense);
                    },
                  ),

                  const SizedBox(height: AppSizes.paddingLg),

                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add any additional details...',
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingXl),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeightLg,
                    child: ElevatedButton(
                      onPressed: formState.isSubmitting ? null : _submitForm,
                      child: formState.isSubmitting
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
                          : const Text('Add Transaction'),
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
