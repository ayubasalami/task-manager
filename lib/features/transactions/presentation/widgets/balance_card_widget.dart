import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_sizes.dart';
import '../../../../core/colors.dart';

class BalanceCard extends StatelessWidget {
  final double currentBalance;
  final double totalIncome;
  final double totalExpenses;

  const BalanceCard({
    super.key,
    required this.currentBalance,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = currentBalance >= 0;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMd),
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF00D09E), const Color(0xFF00B887)]
              : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? AppColors.income : AppColors.expense)
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive ? Icons.account_balance_wallet : Icons.warning,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            _formatAmount(currentBalance, currencyFormat),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: AppSizes.paddingMd),

          Container(height: 1, color: Colors.white.withOpacity(0.3)),

          const SizedBox(height: AppSizes.paddingMd),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Income',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${currencyFormat.format(totalIncome)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_down,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expenses',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '-${currencyFormat.format(totalExpenses)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isPositive) ...[
            const SizedBox(height: AppSizes.paddingMd),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: AppSizes.paddingXs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Balance is negative',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatAmount(double amount, NumberFormat formatter) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = formatter.format(absAmount);
    return isNegative ? '-$formatted' : formatted;
  }
}
