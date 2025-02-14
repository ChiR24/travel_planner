import 'expense.dart';
import 'expense_category.dart';

class Budget {
  final String id;
  final String itineraryId;
  final double totalBudget;
  final String currency;
  final List<Expense> expenses;
  final Map<ExpenseCategory, double> categoryBudgets;

  const Budget({
    required this.id,
    required this.itineraryId,
    required this.totalBudget,
    required this.currency,
    required this.expenses,
    required this.categoryBudgets,
  });

  double get totalExpenses =>
      expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

  double get budgetProgress => totalExpenses / totalBudget;

  double get remainingBudget => totalBudget - totalExpenses;

  Map<ExpenseCategory, double> get categoryProgress {
    final progress = <ExpenseCategory, double>{};
    for (final category in categoryBudgets.keys) {
      final budget = categoryBudgets[category] ?? 0;
      if (budget > 0) {
        final spent = expenses
            .where((e) => e.category == category)
            .fold<double>(0, (sum, e) => sum + e.amount);
        progress[category] = spent / budget;
      } else {
        progress[category] = 0;
      }
    }
    return progress;
  }

  Map<ExpenseCategory, double> get categoryRemaining {
    final remaining = <ExpenseCategory, double>{};
    for (final category in categoryBudgets.keys) {
      final budget = categoryBudgets[category] ?? 0;
      final spent = expenses
          .where((e) => e.category == category)
          .fold<double>(0, (sum, e) => sum + e.amount);
      remaining[category] = budget - spent;
    }
    return remaining;
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      itineraryId: json['itineraryId'] as String,
      totalBudget: (json['totalBudget'] as num).toDouble(),
      currency: json['currency'] as String,
      expenses: (json['expenses'] as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryBudgets: (json['categoryBudgets'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          ExpenseCategory.fromString(key),
          (value as num).toDouble(),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itineraryId': itineraryId,
      'totalBudget': totalBudget,
      'currency': currency,
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'categoryBudgets': categoryBudgets.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
  }

  Budget copyWith({
    String? id,
    String? itineraryId,
    double? totalBudget,
    String? currency,
    List<Expense>? expenses,
    Map<ExpenseCategory, double>? categoryBudgets,
  }) {
    return Budget(
      id: id ?? this.id,
      itineraryId: itineraryId ?? this.itineraryId,
      totalBudget: totalBudget ?? this.totalBudget,
      currency: currency ?? this.currency,
      expenses: expenses ?? this.expenses,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }

  Budget addExpense(Expense expense) {
    return copyWith(
      expenses: [...expenses, expense],
    );
  }

  Budget removeExpense(String expenseId) {
    return copyWith(
      expenses: expenses.where((e) => e.id != expenseId).toList(),
    );
  }

  Budget updateCategoryBudget(ExpenseCategory category, double amount) {
    return copyWith(
      categoryBudgets: {
        ...categoryBudgets,
        category: amount,
      },
    );
  }
}
