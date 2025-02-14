import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/budget.dart' hide Expense;
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/budget_service.dart';

final budgetServiceProvider = Provider<BudgetService>((ref) {
  return BudgetService();
});

final budgetProvider =
    StateNotifierProvider.family<BudgetNotifier, Budget?, String>(
  (ref, itineraryId) => BudgetNotifier(itineraryId),
);

class BudgetNotifier extends StateNotifier<Budget?> {
  final String itineraryId;

  BudgetNotifier(this.itineraryId) : super(null);

  Future<void> createBudget({
    required double totalBudget,
    required String currency,
  }) async {
    final perCategory = totalBudget / ExpenseCategory.values.length;
    final budget = Budget(
      id: const Uuid().v4(),
      itineraryId: itineraryId,
      totalBudget: totalBudget,
      currency: currency,
      expenses: const [],
      categoryBudgets: {
        for (final category in ExpenseCategory.values) category: perCategory,
      },
    );
    state = budget;
  }

  Future<void> addExpense(Expense expense) async {
    if (state == null) return;
    final updatedBudget = Budget(
      id: state!.id,
      itineraryId: state!.itineraryId,
      totalBudget: state!.totalBudget,
      currency: state!.currency,
      expenses: [...state!.expenses, expense],
      categoryBudgets: state!.categoryBudgets,
    );
    state = updatedBudget;
  }

  Future<void> removeExpense(String expenseId) async {
    if (state == null) return;
    final updatedBudget = Budget(
      id: state!.id,
      itineraryId: state!.itineraryId,
      totalBudget: state!.totalBudget,
      currency: state!.currency,
      expenses: state!.expenses.where((e) => e.id != expenseId).toList(),
      categoryBudgets: state!.categoryBudgets,
    );
    state = updatedBudget;
  }

  Future<void> updateCategoryBudget(
    ExpenseCategory category,
    double amount,
  ) async {
    if (state == null) return;
    final updatedBudget = Budget(
      id: state!.id,
      itineraryId: state!.itineraryId,
      totalBudget: state!.totalBudget,
      currency: state!.currency,
      expenses: state!.expenses,
      categoryBudgets: {
        ...state!.categoryBudgets,
        category: amount,
      },
    );
    state = updatedBudget;
  }

  Future<void> updateTotalBudget(double amount) async {
    if (state == null) return;
    final updatedBudget = Budget(
      id: state!.id,
      itineraryId: state!.itineraryId,
      totalBudget: amount,
      currency: state!.currency,
      expenses: state!.expenses,
      categoryBudgets: state!.categoryBudgets,
    );
    state = updatedBudget;
  }
}

final exchangeRatesProvider =
    FutureProvider.family<Map<String, double>, String>((ref, currency) async {
  final budgetService = ref.watch(budgetServiceProvider);
  return budgetService.getExchangeRates(currency);
});

final supportedCurrenciesProvider = FutureProvider<List<String>>((ref) async {
  final budgetService = ref.watch(budgetServiceProvider);
  return budgetService.getSupportedCurrencies();
});
