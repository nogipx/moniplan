import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';
import 'package:moniplan/common/util/export.dart';

@immutable
abstract class OperationEditState {}

class OperationEditInitial extends OperationEditState {}

class OperationEditSuccess extends OperationEditState {
  final Operation value;
  OperationEditSuccess(this.value);
}

class OperationEditCubit extends Cubit<OperationEditState> {
  final Operation? initial;

  late final AdvancedTextEditingController title;
  late final AdvancedTextEditingController expectedMoney;
  late final AdvancedTextEditingController actualMoney;

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

    expectedMoney = AdvancedTextEditingController(
      name: '$runtimeType-money',
      text: _operation.expectedValue == 0
          ? null
          : _operation.expectedValue.isWhole
              ? _operation.expectedValue.toInt().toString()
              : _operation.expectedValue.toString().replaceFirst('.', ','),
    )..addListener(() {
        expectedMoney.createDebounce(() {
          _operation = _operation.copyWith(
            expectedValue: double.tryParse(
                expectedMoney.text.replaceFirst(',', '.').trim()),
          );
          _emitSave;
        });
      });

    actualMoney = AdvancedTextEditingController(
      name: '$runtimeType-actualMoney',
      text: _operation.actualValue == 0 || _operation.actualValue == null
          ? null
          : _operation.actualValue!.isWhole
              ? _operation.actualValue!.toInt().toString()
              : _operation.actualValue.toString().replaceFirst('.', ','),
    )..addListener(() {
        actualMoney.createDebounce(() {
          _operation = _operation.copyWith(
            actualValue:
                double.tryParse(actualMoney.text.replaceFirst(',', '.').trim()),
          );
          _emitSave;
        });
      });

    title = AdvancedTextEditingController(name: '$runtimeType-title')
      ..text = _operation.reason
      ..addListener(() {
        title.createDebounce(() {
          _operation = _operation.copyWith(reason: title.text);
          _emitSave;
        });
      });
  }

  void setOperationExpectedDate(DateTime value) {
    _operation = _operation.copyWith(date: value.date);
    _emitSave;
  }

  void setOperationActualDate() {}

  void resetActualMoney() {
    _operation = _operation.copyWithNull(actualValue: true);
    _emitSave;
  }

  void get _emitSave => emit(OperationEditSuccess(operation));

  String get currencySymbol => _operation.currency.intlSymbol;

  void dispose() {
    title.dispose();
    expectedMoney.dispose();
    actualMoney.dispose();
  }
}
