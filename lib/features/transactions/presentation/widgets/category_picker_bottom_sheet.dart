import 'package:flutter/material.dart';

import '../../../../core/app_sizes.dart';
import '../../../../core/colors.dart';
import '../../domain/entities/transaction_category.dart';

class CategoryPickerBottomSheet extends StatelessWidget {
  final TransactionCategory? selectedCategory;
  final Function(TransactionCategory) onCategorySelected;

  const CategoryPickerBottomSheet({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXl),
          topRight: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSizes.paddingMd),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            child: Text(
              'Select Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLg,
                vertical: AppSizes.paddingSm,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: AppSizes.paddingMd,
                mainAxisSpacing: AppSizes.paddingMd,
              ),
              itemCount: TransactionCategory.values.length,
              itemBuilder: (context, index) {
                final category = TransactionCategory.values[index];
                final isSelected = selectedCategory == category;

                return InkWell(
                  onTap: () {
                    onCategorySelected(category);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color.withOpacity(0.1)
                          : AppColors.grey100,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: isSelected ? category.color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: category.backgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 28,
                          ),
                        ),

                        const SizedBox(height: AppSizes.paddingSm),

                        Text(
                          category.displayName,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? category.color
                                    : AppColors.textPrimary,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSizes.paddingLg),
        ],
      ),
    );
  }
}
