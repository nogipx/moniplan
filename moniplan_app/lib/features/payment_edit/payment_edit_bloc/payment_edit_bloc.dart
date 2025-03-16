import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:async';

import 'payment_edit_event.dart';
import 'payment_edit_state.dart';

/// Блок для управления редактированием платежа
class PaymentEditBloc extends Bloc<PaymentEditEvent, PaymentEditState> {
  /// Функция для сохранения платежа

  PaymentEditBloc({Payment? payment}) : super(PaymentEditState.fromPayment(payment)) {
    on<PaymentEditInitialize>(_onInitialize);
    on<PaymentEditTypeChanged>(_onTypeChanged);
    on<PaymentEditAmountChanged>(_onAmountChanged);
    on<PaymentEditTaxChanged>(_onTaxChanged);
    on<PaymentEditTitleChanged>(_onTitleChanged);
    on<PaymentEditNoteChanged>(_onNoteChanged);
    on<PaymentEditDateChanged>(_onDateChanged);
    on<PaymentEditIsDoneChanged>(_onIsDoneChanged);
    on<PaymentEditRepeatPeriodChanged>(_onRepeatPeriodChanged);
    on<PaymentEditStartDateChanged>(_onStartDateChanged);
    on<PaymentEditEndDateChanged>(_onEndDateChanged);
    on<PaymentEditNextStep>(_onNextStep);
    on<PaymentEditPreviousStep>(_onPreviousStep);
    on<PaymentEditSave>(_onSave);
    on<PaymentEditGoToStep>(_onGoToStep);
    on<PaymentEditUpdateDraft>(_onUpdateDraft);
  }

  /// Обработчик инициализации редактирования платежа
  void _onInitialize(PaymentEditInitialize event, Emitter<PaymentEditState> emit) {
    emit(PaymentEditState.fromPayment(event.payment));
  }

  /// Обработчик изменения типа платежа
  void _onTypeChanged(PaymentEditTypeChanged event, Emitter<PaymentEditState> emit) {
    emit(state.copyWith(type: event.type, clearErrorMessage: true));
    add(const PaymentEditUpdateDraft());
  }

  /// Обработчик изменения суммы платежа
  void _onAmountChanged(PaymentEditAmountChanged event, Emitter<PaymentEditState> emit) {
    emit(state.copyWith(amount: event.amount, clearErrorMessage: true));
    // Не обновляем черновик здесь, так как это делается в _navigateToStep и _savePayment
  }

  /// Обработчик изменения налога
  void _onTaxChanged(PaymentEditTaxChanged event, Emitter<PaymentEditState> emit) {
    emit(state.copyWith(tax: event.tax, clearErrorMessage: true));
    add(const PaymentEditUpdateDraft());
  }

  /// Обработчик изменения названия платежа
  void _onTitleChanged(PaymentEditTitleChanged event, Emitter<PaymentEditState> emit) {
    emit(state.copyWith(title: event.title, clearErrorMessage: true));
    add(const PaymentEditUpdateDraft());
  }

  /// Обработчик изменения примечания к платежу
  void _onNoteChanged(PaymentEditNoteChanged event, Emitter<PaymentEditState> emit) {
    emit(state.copyWith(note: event.note, clearErrorMessage: true));
    add(const PaymentEditUpdateDraft());
  }

  /// Обработчик изменения даты платежа
  void _onDateChanged(PaymentEditDateChanged event, Emitter<PaymentEditState> emit) {
    // Отбрасываем время у даты
    final dateWithoutTime = event.date.dayBound;
    emit(state.copyWith(date: dateWithoutTime, clearErrorMessage: true));
    add(const PaymentEditUpdateDraft());
  }

  /// Обработчик изменения статуса выполнения платежа
  void _onIsDoneChanged(PaymentEditIsDoneChanged event, Emitter<PaymentEditState> emit) {
    emit(state.copyWith(isDone: event.isDone, clearErrorMessage: true));
    add(const PaymentEditUpdateDraft());
  }

  /// Обработчик изменения периода повторения платежа
  void _onRepeatPeriodChanged(
    PaymentEditRepeatPeriodChanged event,
    Emitter<PaymentEditState> emit,
  ) {
    emit(state.copyWith(repeatPeriod: event.repeatPeriod, clearErrorMessage: true));
    add(const PaymentEditUpdateDraft());
  }

  /// Обработчик изменения даты начала повторения
  void _onStartDateChanged(PaymentEditStartDateChanged event, Emitter<PaymentEditState> emit) {
    // Отбрасываем время у даты
    final startDateWithoutTime = event.startDate?.dayBound;
    emit(state.copyWith(startDate: startDateWithoutTime, clearErrorMessage: true));
    add(const PaymentEditUpdateDraft());
  }

  /// Обработчик изменения даты окончания повторения
  void _onEndDateChanged(PaymentEditEndDateChanged event, Emitter<PaymentEditState> emit) {
    // Отбрасываем время у даты
    final endDateWithoutTime = event.endDate?.dayBound;
    emit(state.copyWith(endDate: endDateWithoutTime, clearErrorMessage: true));
    add(const PaymentEditUpdateDraft());
  }

  /// Обработчик перехода к следующему шагу
  void _onNextStep(PaymentEditNextStep event, Emitter<PaymentEditState> emit) {
    // Если мы на первом шаге, переходим ко второму шагу и закрываем клавиатуру
    if (state.currentStep == 0) {
      emit(state.copyWith(currentStep: 1, clearErrorMessage: true));
      return;
    }

    // Переходим к следующему шагу
    if (state.currentStep < 2) {
      emit(state.copyWith(currentStep: state.currentStep + 1, clearErrorMessage: true));
    } else {
      // Если мы на последнем шаге, сохраняем платеж
      add(PaymentEditSave());
    }
  }

  /// Обработчик перехода к предыдущему шагу
  void _onPreviousStep(PaymentEditPreviousStep event, Emitter<PaymentEditState> emit) {
    // Переходим к предыдущему шагу
    if (state.currentStep > 0) {
      final newStep = state.currentStep - 1;

      // Если переходим на первый шаг, показываем клавиатуру
      emit(
        state.copyWith(
          currentStep: newStep,
          showKeyboard: newStep == 0,
          keyboardType: newStep == 0 ? KeyboardType.amount : state.keyboardType,
          clearErrorMessage: true,
        ),
      );
    }
  }

  /// Обработчик сохранения платежа
  FutureOr<void> _onSave(PaymentEditSave event, Emitter<PaymentEditState> emit) async {
    try {
      // Проверяем, что сумма платежа является числом
      final amount = double.tryParse(state.amount);
      if (amount == null) {
        emit(
          state.copyWith(
            status: PaymentEditStatus.failure,
            errorMessage: 'Сумма платежа должна быть числом',
          ),
        );
        return;
      }

      // Создаем платеж из текущего состояния
      Payment? payment;

      try {
        payment = state.toPayment();
      } catch (e) {
        // В случае ошибки при создании платежа
        print('Ошибка при создании платежа: $e');

        // Используем существующий платеж, если он есть
        payment = state.payment;

        // Если платежа нет, выбрасываем исключение
        if (payment == null) {
          throw Exception('Не удалось создать платеж: $e');
        }
      }

      // Эмитим состояние с успешным сохранением
      emit(state.copyWith(status: PaymentEditStatus.success, payment: payment));
    } catch (e) {
      // Эмитим состояние с ошибкой
      emit(
        state.copyWith(
          status: PaymentEditStatus.failure,
          errorMessage: 'Ошибка при сохранении платежа: $e',
        ),
      );
    }
  }

  /// Обработчик прямого перехода на указанный шаг
  void _onGoToStep(PaymentEditGoToStep event, Emitter<PaymentEditState> emit) {
    // Проверяем, что шаг находится в допустимом диапазоне
    if (event.step < 0 || event.step > 2) return;

    // Если переходим на первый шаг, показываем клавиатуру
    final showKeyboard = event.step == 0;

    // Обновляем состояние
    emit(
      state.copyWith(
        currentStep: event.step,
        showKeyboard: showKeyboard,
        keyboardType: showKeyboard ? KeyboardType.amount : state.keyboardType,
        clearErrorMessage: true,
      ),
    );
  }

  /// Обработчик обновления черновика платежа
  void _onUpdateDraft(PaymentEditUpdateDraft event, Emitter<PaymentEditState> emit) {
    try {
      // Создаем платеж из текущего состояния
      final payment = state.toPayment();

      // Обновляем состояние с новым платежом
      emit(state.copyWith(payment: payment, clearErrorMessage: true));
    } catch (e) {
      // В случае ошибки просто логируем её, но не меняем состояние
      print('Ошибка при обновлении черновика платежа: $e');
    }
  }
}
