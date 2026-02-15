import 'package:flutter/material.dart';

enum TransactionCategory {
  groceries,
  transportation,
  dining,
  entertainment,
  healthcare,
  shopping,
  utilities;

  String get displayName {
    switch (this) {
      case TransactionCategory.groceries:
        return 'Groceries';
      case TransactionCategory.transportation:
        return 'Transportation';
      case TransactionCategory.dining:
        return 'Dining';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.healthcare:
        return 'Healthcare';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.utilities:
        return 'Utilities';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.groceries:
        return Icons.shopping_cart;
      case TransactionCategory.transportation:
        return Icons.local_gas_station;
      case TransactionCategory.dining:
        return Icons.restaurant;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.healthcare:
        return Icons.medical_services;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.utilities:
        return Icons.lightbulb;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.groceries:
        return const Color(0xFF4CAF50);
      case TransactionCategory.transportation:
        return const Color(0xFF2196F3);
      case TransactionCategory.dining:
        return const Color(0xFFFF9800);
      case TransactionCategory.entertainment:
        return const Color(0xFF9C27B0);
      case TransactionCategory.healthcare:
        return const Color(0xFFF44336);
      case TransactionCategory.shopping:
        return const Color(0xFFE91E63);
      case TransactionCategory.utilities:
        return const Color(0xFFFFEB3B);
    }
  }

  Color get backgroundColor {
    return color.withOpacity(0.1);
  }

  static TransactionCategory fromString(String category) {
    return TransactionCategory.values.firstWhere(
      (e) => e.displayName.toLowerCase() == category.toLowerCase(),
      orElse: () => TransactionCategory.shopping,
    );
  }

  static List<String> get allCategories {
    return TransactionCategory.values.map((e) => e.displayName).toList();
  }
}
