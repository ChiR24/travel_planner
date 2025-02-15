import 'expense_category.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? notes;
  final String budgetId;

  const Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.budgetId,
    this.notes,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.fromString(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      budgetId: json['budgetId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category.toString(),
      'date': date.toIso8601String(),
      'budgetId': budgetId,
      if (notes != null) 'notes': notes,
    };
  }

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? notes,
    String? budgetId,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      budgetId: budgetId ?? this.budgetId,
    );
  }
}
