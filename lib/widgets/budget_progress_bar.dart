import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/budget_service.dart';
import '../services/expenses_service.dart';
import '../models/budget.dart';

class BudgetProgressBar extends StatelessWidget {
  final String userId;

  const BudgetProgressBar({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Budget?>(
      future: BudgetService(userId).getCurrentMonthBudget(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final monthlyBudget = snapshot.data?.amount ?? 5000.0;
        return FutureBuilder<Map<String, double>>(
          future: ExpensesService(userId).getCurrentMonthExpenses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final expenses = snapshot.data ?? {};
            final totalSpent = expenses.values.fold(0.0, (sum, amount) => sum + amount);
            final spentPercentage = (totalSpent / monthlyBudget).clamp(0.0, 1.0);
            final isOverBudget = totalSpent > monthlyBudget;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget for ${DateFormat('MMM yyyy').format(DateTime.now())}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '\$${totalSpent.toStringAsFixed(2)} / \$${monthlyBudget.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isOverBudget ? Colors.red : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        color: Colors.grey[200],
                      ),
                      FractionallySizedBox(
                        widthFactor: spentPercentage,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: isOverBudget 
                                ? Colors.red 
                                : (spentPercentage > 0.8 ? Colors.orange : Colors.green),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (isOverBudget)
                  const Text(
                    '⚠️ Over budget!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (spentPercentage > 0.8)
                  const Text(
                    '⚠️ Approaching budget limit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}