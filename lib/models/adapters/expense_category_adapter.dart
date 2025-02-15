import 'package:hive/hive.dart';
import '../expense_category.dart';

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 3; // Unique ID for this adapter

  @override
  ExpenseCategory read(BinaryReader reader) {
    return ExpenseCategory.fromString(reader.readString());
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    writer.writeString(obj.toString());
  }
}
