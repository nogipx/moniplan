import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:dartx/dartx.dart';

@immutable
abstract class OperationEditState {}

class OperationEditInitial extends OperationEditState {}

class OperationEditSuccess extends OperationEditState {
  final Operation value;
  OperationEditSuccess(this.value);
}

class OperationEditCubit extends Cubit<OperationEditState> {
  final Operation? initial;

  late final TextEditingController title;
  late final TextEditingController money;
  late final TextEditingController actualMoney;
  late Operation _operation;
  Operation get operation => _operation;

  OperationEditCubit({
    this.initial,
  }) : super(OperationEditInitial()) {
    _operation = initial?.copyWith() ??
        Operation.create(
          expectedValue: 0,
          reason: "",
          date: DateTime.now(),
          currency: CommonCurrencies().rub,
        );

    money = TextEditingController(
        text: _operation.expectedValue == 0
            ? null
            : _operation.expectedValue.isWhole
                ? _operation.expectedValue.toInt().toString()
                : _operation.expectedValue.toString())
      ..addListener(() {
        _operation = _operation.copyWith(
          expectedValue: double.tryParse(money.text.trim()),
        );
      });

    actualMoney = TextEditingController(
        text: _operation.actualValue == 0 || _operation.actualValue == null
            ? null
            : _operation.actualValue!.isWhole
                ? _operation.actualValue!.toInt().toString()
                : _operation.actualValue.toString())
      ..addListener(() {
        final newOperation = _operation.copyWith(
          actualValue: double.tryParse(actualMoney.text.trim()),
        );
        _operation = newOperation;
        print(_operation.actualValue);
      });

    title = TextEditingController()
      ..text = _operation.reason
      ..addListener(() {
        _operation = _operation.copyWith(reason: title.text);
      });
  }

  void setOperationExpectedDate(DateTime value) {
    _operation = _operation..copyWith(date: value.date);
  }

  void setOperationActualDate() {}

  void resetActualMoney() {
    _operation = _operation.copyWithNull(actualValue: true);
  }

  String get currencySymbol => _operation.currency.intlSymbol;

  void dispose() {
    title.dispose();
    money.dispose();
    actualMoney.dispose();
  }
}
