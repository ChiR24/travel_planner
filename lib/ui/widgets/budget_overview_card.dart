import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/budget.dart' hide Expense;
import '../../models/expense.dart';
import '../../providers/budget_provider.dart';
import 'add_expense_dialog.dart';

class BudgetOverviewCard extends ConsumerWidget {
  final String itineraryId;

  const BudgetOverviewCard({
    super.key,
    required this.itineraryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetProvider(itineraryId));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (budgetAsync == null)
                  ElevatedButton.icon(
                    onPressed: () => _setupBudget(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Set Up Budget'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (budgetAsync != null) ...[
              _buildBudgetProgress(context, budgetAsync),
              const SizedBox(height: 16),
              _buildCategoryBreakdown(context, budgetAsync),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _addExpense(context, ref, budgetAsync),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgress(BuildContext context, Budget budget) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        LinearProgressIndicator(
          value: budget.budgetProgress,
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            budget.budgetProgress > 0.9
                ? Colors.red
                : budget.budgetProgress > 0.7
                    ? Colors.orange
                    : colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent: ${budget.currency} ${budget.totalExpenses.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              'Total: ${budget.currency} ${budget.totalBudget.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, Budget budget) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: budget.categoryProgress.entries.map((entry) {
        final progress = entry.value;
        final remaining = budget.categoryRemaining[entry.key] ?? 0;
        final isOverBudget = remaining < 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${entry.key.icon} ${entry.key.label}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${budget.currency} ${remaining.abs().toStringAsFixed(2)} ${isOverBudget ? 'over' : 'left'}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isOverBudget ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 1
                      ? Colors.red
                      : progress > 0.9
                          ? Colors.orange
                          : colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _setupBudget(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Set Up Budget',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Total Budget',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Handle budget input
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Currency',
              ),
              items: ['USD', 'EUR', 'GBP', 'JPY']
                  .map((currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      ))
                  .toList(),
              onChanged: (value) {
                // Handle currency selection
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Create budget
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(budgetProvider(itineraryId).notifier).createBudget(
            totalBudget: result['totalBudget'] as double,
            currency: result['currency'] as String,
          );
    }
  }

  Future<void> _addExpense(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final expense = await showDialog<Expense>(
      context: context,
      builder: (context) => AddExpenseDialog(
        currency: budget.currency,
        budgetId: budget.id,
      ),
    );

    if (expense != null) {
      await ref.read(budgetProvider(itineraryId).notifier).addExpense(expense);
    }
  }
}
