import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/budget.dart' hide Expense;
import '../models/expense.dart';
import '../models/expense_category.dart';

class BudgetService {
  final String _exchangeRateApiKey = 'YOUR_EXCHANGE_RATE_API_KEY';
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  final _uuid = const Uuid();

  Future<Budget> createBudget({
    required String itineraryId,
    required double totalBudget,
    required String currency,
  }) async {
    final perCategory = totalBudget / ExpenseCategory.values.length;
    final categoryBudgets = {
      for (final category in ExpenseCategory.values) category: perCategory,
    };

    final budget = Budget(
      id: _uuid.v4(),
      itineraryId: itineraryId,
      totalBudget: totalBudget,
      currency: currency,
      expenses: const [],
      categoryBudgets: categoryBudgets,
    );

    // TODO: Save budget to storage
    return budget;
  }

  Future<Budget> addExpense(Budget budget, Expense expense) async {
    final updatedBudget = Budget(
      id: budget.id,
      itineraryId: budget.itineraryId,
      totalBudget: budget.totalBudget,
      currency: budget.currency,
      expenses: [...budget.expenses, expense],
      categoryBudgets: budget.categoryBudgets,
    );

    // TODO: Save updated budget to storage
    return updatedBudget;
  }

  Future<Budget> updateExpense(Budget budget, Expense updatedExpense) async {
    final expenses = budget.expenses.map((e) {
      if (e.id == updatedExpense.id) {
        return updatedExpense;
      }
      return e;
    }).toList();

    final updatedBudget = Budget(
      id: budget.id,
      itineraryId: budget.itineraryId,
      totalBudget: budget.totalBudget,
      currency: budget.currency,
      expenses: expenses,
      categoryBudgets: budget.categoryBudgets,
    );

    // TODO: Save updated budget to storage
    return updatedBudget;
  }

  Future<Budget> deleteExpense(Budget budget, String expenseId) async {
    final updatedBudget = Budget(
      id: budget.id,
      itineraryId: budget.itineraryId,
      totalBudget: budget.totalBudget,
      currency: budget.currency,
      expenses: budget.expenses.where((e) => e.id != expenseId).toList(),
      categoryBudgets: budget.categoryBudgets,
    );

    // TODO: Save updated budget to storage
    return updatedBudget;
  }

  Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$baseCurrency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, double>.from(data['rates']);
      }

      throw Exception('Failed to get exchange rates');
    } catch (e) {
      throw Exception('Error getting exchange rates: $e');
    }
  }

  Future<double> convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;

    try {
      final rates = await getExchangeRates(fromCurrency);
      final rate = rates[toCurrency];

      if (rate == null) {
        throw Exception('Exchange rate not found for $toCurrency');
      }

      return amount * rate;
    } catch (e) {
      throw Exception('Error converting currency: $e');
    }
  }

  Future<List<String>> getSupportedCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/USD'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, dynamic>.from(data['rates']);
        return rates.keys.toList()..sort();
      }

      throw Exception('Failed to get supported currencies');
    } catch (e) {
      throw Exception('Error getting supported currencies: $e');
    }
  }

  Future<Budget?> getBudgetForItinerary(String itineraryId) async {
    // TODO: Implement storage retrieval
    return null;
  }

  Future<void> saveBudget(Budget budget) async {
    // TODO: Implement storage
  }
}
