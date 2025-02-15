import 'package:hive/hive.dart';
import '../expense.dart';
import '../expense_category.dart';

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 1; // Unique ID for this adapter

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Expense(
      id: fields[0] as String,
      description: fields[1] as String,
      amount: fields[2] as double,
      category: fields[3] as ExpenseCategory,
      date: fields[4] as DateTime,
      notes: fields[5] as String?,
      budgetId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.budgetId);
  }
}
