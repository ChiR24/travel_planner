import 'package:hive/hive.dart';
import '../budget.dart';
import '../expense_category.dart';
import '../expense.dart';

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 2; // Unique ID for this adapter

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Budget(
      id: fields[0] as String,
      itineraryId: fields[1] as String,
      totalBudget: fields[2] as double,
      currency: fields[3] as String,
      expenses: (fields[4] as List).cast<Expense>(),
      categoryBudgets: (fields[5] as Map).cast<ExpenseCategory, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itineraryId)
      ..writeByte(2)
      ..write(obj.totalBudget)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.expenses)
      ..writeByte(5)
      ..write(obj.categoryBudgets);
  }
}
