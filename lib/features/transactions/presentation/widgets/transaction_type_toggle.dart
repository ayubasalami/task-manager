import 'package:flutter/material.dart';

import '../../../../core/app_sizes.dart';
import '../../../../core/colors.dart';

class TransactionTypeToggle extends StatelessWidget {
  final bool isExpense;
  final Function(bool) onChanged;

  const TransactionTypeToggle({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: 'Expense',
            icon: Icons.trending_down,
            color: AppColors.expense,
            isSelected: isExpense,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: AppSizes.paddingMd),
        Expanded(
          child: _TypeButton(
            label: 'Income',
            icon: Icons.trending_up,
            color: AppColors.income,
            isSelected: !isExpense,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingMd,
          horizontal: AppSizes.paddingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: AppSizes.paddingSm),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
