import 'package:equatable/equatable.dart';
import 'package:moniplan_app/core/_index.dart';

/// События для блока редактирования платежа
abstract class PaymentEditEvent extends Equatable {
  const PaymentEditEvent();

  @override
  List<Object?> get props => [];
}

/// Инициализация редактирования платежа
class PaymentEditInitialize extends PaymentEditEvent {
  final Payment? payment;

  const PaymentEditInitialize({this.payment});

  @override
  List<Object?> get props => [payment];
}

/// Изменение типа платежа (доход/расход)
class PaymentEditTypeChanged extends PaymentEditEvent {
  final PaymentType type;

  const PaymentEditTypeChanged(this.type);

  @override
  List<Object> get props => [type];
}

/// Изменение суммы платежа
class PaymentEditAmountChanged extends PaymentEditEvent {
  final String amount;

  const PaymentEditAmountChanged(this.amount);

  @override
  List<Object> get props => [amount];
}

/// Изменение налога
class PaymentEditTaxChanged extends PaymentEditEvent {
  final String tax;

  const PaymentEditTaxChanged(this.tax);

  @override
  List<Object> get props => [tax];
}

/// Изменение названия платежа
class PaymentEditTitleChanged extends PaymentEditEvent {
  final String title;

  const PaymentEditTitleChanged(this.title);

  @override
  List<Object> get props => [title];
}

/// Изменение примечания к платежу
class PaymentEditNoteChanged extends PaymentEditEvent {
  final String note;

  const PaymentEditNoteChanged(this.note);

  @override
  List<Object> get props => [note];
}

/// Изменение даты платежа
class PaymentEditDateChanged extends PaymentEditEvent {
  final DateTime date;

  const PaymentEditDateChanged(this.date);

  @override
  List<Object> get props => [date];
}

/// Изменение статуса выполнения платежа
class PaymentEditIsDoneChanged extends PaymentEditEvent {
  final bool isDone;

  const PaymentEditIsDoneChanged({required this.isDone});

  @override
  List<Object> get props => [isDone];
}

/// Изменение периода повторения платежа
class PaymentEditRepeatPeriodChanged extends PaymentEditEvent {
  final DateTimeRepeat repeatPeriod;

  const PaymentEditRepeatPeriodChanged(this.repeatPeriod);

  @override
  List<Object> get props => [repeatPeriod];
}

/// Изменение даты начала повторения
class PaymentEditStartDateChanged extends PaymentEditEvent {
  final DateTime? startDate;

  const PaymentEditStartDateChanged(this.startDate);

  @override
  List<Object?> get props => [startDate];
}

/// Изменение даты окончания повторения
class PaymentEditEndDateChanged extends PaymentEditEvent {
  final DateTime? endDate;

  const PaymentEditEndDateChanged(this.endDate);

  @override
  List<Object?> get props => [endDate];
}

/// Обновление черновика платежа
class PaymentEditUpdateDraft extends PaymentEditEvent {
  const PaymentEditUpdateDraft();

  @override
  List<Object?> get props => [];
}

/// Переход к следующему шагу редактирования
class PaymentEditNextStep extends PaymentEditEvent {}

/// Переход к предыдущему шагу редактирования
class PaymentEditPreviousStep extends PaymentEditEvent {}

/// Прямой переход на указанный шаг редактирования
class PaymentEditGoToStep extends PaymentEditEvent {
  final int step;

  const PaymentEditGoToStep(this.step);

  @override
  List<Object> get props => [step];
}

/// Сохранение платежа
class PaymentEditSave extends PaymentEditEvent {}
