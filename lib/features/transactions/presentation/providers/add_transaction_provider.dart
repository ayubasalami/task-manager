import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/transaction_category.dart';
import '../../domain/entities/transaction_model.dart';
import 'transaction_provider.dart';

class AddTransactionFormState {
  final double? amount;
  final String? merchant;
  final TransactionCategory? category;
  final DateTime selectedDate;
  final bool isExpense;
  final String? notes;
  final bool isSubmitting;
  final String? error;

  AddTransactionFormState({
    this.amount,
    this.merchant,
    this.category,
    DateTime? selectedDate,
    this.isExpense = true,
    this.notes,
    this.isSubmitting = false,
    this.error,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AddTransactionFormState copyWith({
    double? amount,
    String? merchant,
    TransactionCategory? category,
    DateTime? selectedDate,
    bool? isExpense,
    String? notes,
    bool? isSubmitting,
    String? error,
  }) {
    return AddTransactionFormState(
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      selectedDate: selectedDate ?? this.selectedDate,
      isExpense: isExpense ?? this.isExpense,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }

  bool get isValid {
    return amount != null &&
        amount! > 0 &&
        merchant != null &&
        merchant!.isNotEmpty &&
        category != null;
  }
}

class AddTransactionFormNotifier
    extends StateNotifier<AddTransactionFormState> {
  final Ref ref;

  AddTransactionFormNotifier(this.ref) : super(AddTransactionFormState());

  void setAmount(double? amount) {
    state = state.copyWith(amount: amount);
  }

  void setMerchant(String? merchant) {
    state = state.copyWith(merchant: merchant);
  }

  void setCategory(TransactionCategory? category) {
    state = state.copyWith(category: category);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setIsExpense(bool isExpense) {
    state = state.copyWith(isExpense: isExpense);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  Future<bool> submitTransaction() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please fill in all required fields');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: state.isExpense ? -state.amount! : state.amount!,
        merchant: state.merchant!,
        category: state.category!.displayName,
        date: state.selectedDate,
        status: TransactionStatus.completed,
      );

      final repository = ref.read(transactionRepositoryProvider);
      final success = await repository.addTransaction(transaction);

      if (!success) {
        state = state.copyWith(
          isSubmitting: false,
          error:
              'Failed to save transaction. Please check storage permissions and try again.',
        );
        return false;
      }

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to add transaction: ${e.toString()}',
      );
      return false;
    }
  }

  void reset() {
    state = AddTransactionFormState();
  }
}

final addTransactionFormProvider =
    StateNotifierProvider.autoDispose<
      AddTransactionFormNotifier,
      AddTransactionFormState
    >((ref) {
      return AddTransactionFormNotifier(ref);
    });
