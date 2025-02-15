import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/itinerary.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/adapters/itinerary_adapter.dart';
import '../models/adapters/expense_adapter.dart';
import '../models/adapters/budget_adapter.dart';
import '../models/adapters/expense_category_adapter.dart';

class OfflineStorageException implements Exception {
  final String message;
  final String operation;
  final Object? originalError;

  OfflineStorageException(this.message, this.operation, [this.originalError]);

  @override
  String toString() =>
      'OfflineStorageException: $message (during $operation)${originalError != null ? '\nOriginal error: $originalError' : ''}';
}

class OfflineStorageService {
  static const String _itinerariesBox = 'itineraries';
  static const String _expensesBox = 'expenses';
  static const String _budgetsBox = 'budgets';
  static const String _documentsBox = 'documents';
  static const String _lastSyncKey = 'last_sync';
  bool _isInitialized = false;

  // Initialize Hive and open boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0))
        Hive.registerAdapter(ItineraryAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ExpenseAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(BudgetAdapter());
      if (!Hive.isAdapterRegistered(3))
        Hive.registerAdapter(ExpenseCategoryAdapter());

      // Open boxes
      await Hive.openBox<Itinerary>(_itinerariesBox);
      await Hive.openBox<Expense>(_expensesBox);
      await Hive.openBox<Budget>(_budgetsBox);
      await Hive.openBox(_documentsBox);

      _isInitialized = true;
    } catch (e) {
      throw OfflineStorageException(
        'Failed to initialize offline storage',
        'initialize',
        e,
      );
    }
  }

  // Validation methods
  void _validateInitialization() {
    if (!_isInitialized) {
      throw OfflineStorageException(
        'Storage not initialized',
        'validation',
      );
    }
  }

  void _validateItinerary(Itinerary itinerary) {
    if (itinerary.id.isEmpty) {
      throw OfflineStorageException(
        'Itinerary ID cannot be empty',
        'validation',
      );
    }
    if (itinerary.destinations.isEmpty) {
      throw OfflineStorageException(
        'Itinerary must have at least one destination',
        'validation',
      );
    }
    if (itinerary.endDate.isBefore(itinerary.startDate)) {
      throw OfflineStorageException(
        'End date cannot be before start date',
        'validation',
      );
    }
  }

  void _validateExpense(Expense expense) {
    if (expense.id.isEmpty) {
      throw OfflineStorageException(
        'Expense ID cannot be empty',
        'validation',
      );
    }
    if (expense.amount <= 0) {
      throw OfflineStorageException(
        'Expense amount must be greater than zero',
        'validation',
      );
    }
    if (expense.budgetId.isEmpty) {
      throw OfflineStorageException(
        'Expense must be associated with a budget',
        'validation',
      );
    }
  }

  void _validateBudget(Budget budget) {
    if (budget.id.isEmpty) {
      throw OfflineStorageException(
        'Budget ID cannot be empty',
        'validation',
      );
    }
    if (budget.totalBudget <= 0) {
      throw OfflineStorageException(
        'Total budget must be greater than zero',
        'validation',
      );
    }
    if (budget.itineraryId.isEmpty) {
      throw OfflineStorageException(
        'Budget must be associated with an itinerary',
        'validation',
      );
    }
  }

  // Itineraries
  Future<void> saveItinerary(Itinerary itinerary) async {
    try {
      _validateInitialization();
      _validateItinerary(itinerary);

      final box = Hive.box<Itinerary>(_itinerariesBox);
      await box.put(itinerary.id, itinerary);
    } catch (e) {
      throw OfflineStorageException(
        'Failed to save itinerary',
        'saveItinerary',
        e,
      );
    }
  }

  Future<Itinerary?> getItinerary(String id) async {
    try {
      _validateInitialization();
      if (id.isEmpty) {
        throw OfflineStorageException(
          'Itinerary ID cannot be empty',
          'getItinerary',
        );
      }

      final box = Hive.box<Itinerary>(_itinerariesBox);
      return box.get(id);
    } catch (e) {
      throw OfflineStorageException(
        'Failed to get itinerary',
        'getItinerary',
        e,
      );
    }
  }

  Future<List<Itinerary>> getAllItineraries() async {
    try {
      _validateInitialization();
      final box = Hive.box<Itinerary>(_itinerariesBox);
      return box.values.toList();
    } catch (e) {
      throw OfflineStorageException(
        'Failed to get all itineraries',
        'getAllItineraries',
        e,
      );
    }
  }

  // Expenses
  Future<void> saveExpense(Expense expense) async {
    try {
      _validateInitialization();
      _validateExpense(expense);

      final box = Hive.box<Expense>(_expensesBox);
      await box.put(expense.id, expense);
    } catch (e) {
      throw OfflineStorageException(
        'Failed to save expense',
        'saveExpense',
        e,
      );
    }
  }

  Future<List<Expense>> getExpensesForBudget(String budgetId) async {
    try {
      _validateInitialization();
      if (budgetId.isEmpty) {
        throw OfflineStorageException(
          'Budget ID cannot be empty',
          'getExpensesForBudget',
        );
      }

      final box = Hive.box<Expense>(_expensesBox);
      return box.values
          .where((expense) => expense.budgetId == budgetId)
          .toList();
    } catch (e) {
      throw OfflineStorageException(
        'Failed to get expenses for budget',
        'getExpensesForBudget',
        e,
      );
    }
  }

  // Budgets
  Future<void> saveBudget(Budget budget) async {
    try {
      _validateInitialization();
      _validateBudget(budget);

      final box = Hive.box<Budget>(_budgetsBox);
      await box.put(budget.id, budget);
    } catch (e) {
      throw OfflineStorageException(
        'Failed to save budget',
        'saveBudget',
        e,
      );
    }
  }

  Future<Budget?> getBudget(String id) async {
    try {
      _validateInitialization();
      if (id.isEmpty) {
        throw OfflineStorageException(
          'Budget ID cannot be empty',
          'getBudget',
        );
      }

      final box = Hive.box<Budget>(_budgetsBox);
      return box.get(id);
    } catch (e) {
      throw OfflineStorageException(
        'Failed to get budget',
        'getBudget',
        e,
      );
    }
  }

  // Documents
  Future<void> saveDocument(String id, Map<String, dynamic> document) async {
    try {
      _validateInitialization();
      if (id.isEmpty) {
        throw OfflineStorageException(
          'Document ID cannot be empty',
          'saveDocument',
        );
      }

      final box = Hive.box(_documentsBox);
      await box.put(id, Map<String, dynamic>.from(document));
    } catch (e) {
      throw OfflineStorageException(
        'Failed to save document',
        'saveDocument',
        e,
      );
    }
  }

  Future<Map<String, dynamic>?> getDocument(String id) async {
    try {
      _validateInitialization();
      if (id.isEmpty) {
        throw OfflineStorageException(
          'Document ID cannot be empty',
          'getDocument',
        );
      }

      final box = Hive.box(_documentsBox);
      final doc = box.get(id);
      return doc != null ? Map<String, dynamic>.from(doc) : null;
    } catch (e) {
      throw OfflineStorageException(
        'Failed to get document',
        'getDocument',
        e,
      );
    }
  }

  // Sync management
  Future<DateTime?> getLastSyncTime() async {
    final box = Hive.box<Map>(_documentsBox);
    final timestamp = box.get(_lastSyncKey)?['timestamp'];
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  Future<void> updateLastSyncTime() async {
    final box = Hive.box<Map>(_documentsBox);
    await box.put(_lastSyncKey, {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Clear data
  Future<void> clearAllData() async {
    try {
      _validateInitialization();
      await Future.wait([
        Hive.box<Itinerary>(_itinerariesBox).clear(),
        Hive.box<Expense>(_expensesBox).clear(),
        Hive.box<Budget>(_budgetsBox).clear(),
        Hive.box(_documentsBox).clear(),
      ]);
    } catch (e) {
      throw OfflineStorageException(
        'Failed to clear all data',
        'clearAllData',
        e,
      );
    }
  }

  // Close boxes
  Future<void> dispose() async {
    try {
      await Hive.close();
      _isInitialized = false;
    } catch (e) {
      throw OfflineStorageException(
        'Failed to dispose storage',
        'dispose',
        e,
      );
    }
  }
}
