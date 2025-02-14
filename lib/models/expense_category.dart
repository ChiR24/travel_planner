enum ExpenseCategory {
  accommodation('🏨', 'Accommodation'),
  transportation('🚗', 'Transportation'),
  food('🍽️', 'Food & Drinks'),
  activities('🎯', 'Activities'),
  shopping('🛍️', 'Shopping'),
  other('💰', 'Other');

  final String icon;
  final String label;

  const ExpenseCategory(this.icon, this.label);

  @override
  String toString() => label;

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.label == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
