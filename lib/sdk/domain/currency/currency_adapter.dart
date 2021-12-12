import 'package:hive/hive.dart';
import 'package:moniplan/sdk/domain.dart';

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final int typeId = HiveTypes.Currency;

  @override
  Currency read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Currency.create(
      fields[0] as String,
      fields[2] as int,
      symbol: fields[1] as String,
      pattern: fields[3] as String,
      invertSeparators: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.symbol)
      ..writeByte(2)
      ..write(obj.scale)
      ..writeByte(3)
      ..write(obj.pattern)
      ..writeByte(4)
      ..write(obj.invertSeparators)
      ..writeByte(5)
      ..write(obj.decimalSeparator)
      ..writeByte(6)
      ..write(obj.groupSeparator);
  }
}
