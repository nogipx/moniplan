import 'package:equatable/equatable.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

/// Состояние для блока редактирования платежа
class PaymentEditState extends Equatable {
  /// Текущий редактируемый платеж
  final Payment? payment;

  /// Название платежа
  final String title;

  /// Сумма платежа (строка для отображения)
  final String amount;

  /// Примечание к платежу
  final String note;

  /// Налог (строка для отображения)
  final String tax;

  /// Дата платежа
  final DateTime date;

  /// Статус выполнения платежа
  final bool isDone;

  /// Тип платежа (доход/расход)
  final PaymentType type;

  /// Период повторения платежа
  final DateTimeRepeat repeatPeriod;

  /// Дата начала повторения
  final DateTime? startDate;

  /// Дата окончания повторения
  final DateTime? endDate;

  /// Текущий шаг редактирования (0 - сумма, 1 - название, 2 - повторение)
  final int currentStep;

  /// Показывать ли клавиатуру
  final bool showKeyboard;

  /// Тип активной клавиатуры
  final KeyboardType keyboardType;

  /// Статус сохранения
  final PaymentEditStatus status;

  /// Сообщение об ошибке
  final String? errorMessage;

  // Используем фабрику для создания объекта с текущей датой
  factory PaymentEditState({
    Payment? payment,
    String title = '',
    String amount = '',
    String note = '',
    String tax = '',
    DateTime? date,
    bool isDone = false,
    PaymentType type = PaymentType.expense,
    DateTimeRepeat repeatPeriod = DateTimeRepeat.noRepeat,
    DateTime? startDate,
    DateTime? endDate,
    int currentStep = 0,
    bool showKeyboard = true,
    KeyboardType keyboardType = KeyboardType.amount,
    PaymentEditStatus status = PaymentEditStatus.initial,
    String? errorMessage,
  }) {
    return PaymentEditState._internal(
      payment: payment,
      title: title,
      amount: amount,
      note: note,
      tax: tax,
      date: date ?? DateTime.now(),
      isDone: isDone,
      type: type,
      repeatPeriod: repeatPeriod,
      startDate: startDate,
      endDate: endDate,
      currentStep: currentStep,
      showKeyboard: showKeyboard,
      keyboardType: keyboardType,
      status: status,
      errorMessage: errorMessage,
    );
  }

  // Внутренний конструктор с обязательными параметрами
  const PaymentEditState._internal({
    required this.payment,
    required this.title,
    required this.amount,
    required this.note,
    required this.tax,
    required this.date,
    required this.isDone,
    required this.type,
    required this.repeatPeriod,
    required this.startDate,
    required this.endDate,
    required this.currentStep,
    required this.showKeyboard,
    required this.keyboardType,
    required this.status,
    required this.errorMessage,
  });

  /// Создает копию состояния с новыми значениями
  PaymentEditState copyWith({
    Payment? payment,
    String? title,
    String? amount,
    String? note,
    String? tax,
    DateTime? date,
    bool? isDone,
    PaymentType? type,
    DateTimeRepeat? repeatPeriod,
    DateTime? startDate,
    DateTime? endDate,
    int? currentStep,
    bool? showKeyboard,
    KeyboardType? keyboardType,
    PaymentEditStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PaymentEditState._internal(
      payment: payment ?? this.payment,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      tax: tax ?? this.tax,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      type: type ?? this.type,
      repeatPeriod: repeatPeriod ?? this.repeatPeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currentStep: currentStep ?? this.currentStep,
      showKeyboard: showKeyboard ?? this.showKeyboard,
      keyboardType: keyboardType ?? this.keyboardType,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Создает начальное состояние из платежа
  factory PaymentEditState.fromPayment(Payment? payment) {
    if (payment == null) {
      return PaymentEditState(
        date: DateTime.now(),
        showKeyboard: true,
        keyboardType: KeyboardType.amount,
      );
    }

    // Преобразуем налог из десятичной дроби в проценты
    String taxPercent = '';
    if (payment.details.tax != null) {
      taxPercent = (payment.details.tax! * 100).toInt().toString();
    }

    return PaymentEditState(
      payment: payment,
      title: payment.details.name,
      amount: payment.details.money.abs().toString(),
      note: payment.details.note,
      tax: taxPercent, // Используем проценты для отображения
      date: payment.date,
      isDone: payment.isDone,
      type: payment.details.type,
      repeatPeriod: payment.repeat,
      startDate: payment.dateStart,
      endDate: payment.dateEnd,
      showKeyboard: true,
      keyboardType: KeyboardType.amount,
    );
  }

  /// Проверяет, валидно ли состояние для сохранения
  bool get isValid {
    // Проверяем, что сумма не пустая и может быть преобразована в число
    if (amount.isEmpty) {
      return false;
    }

    // Пытаемся преобразовать сумму в число
    final amountValue = double.tryParse(amount.replaceAll(',', '.'));
    if (amountValue == null || amountValue <= 0) {
      return false;
    }

    return true;
  }

  /// Создает объект платежа из текущего состояния
  Payment toPayment() {
    // Парсим сумму
    final amountValue = double.tryParse(amount.replaceAll(',', '.'))?.toInt() ?? 0;

    // Парсим налог (значение уже в процентах, нужно преобразовать в десятичную дробь)
    final taxPercent = double.tryParse(tax.replaceAll(',', '.')) ?? 0;
    final taxRate = taxPercent / 100; // Преобразуем проценты в десятичную дробь

    // Создаем или обновляем платеж
    return payment?.copyWith(
          isEnabled: true,
          isDone: isDone,
          date: date,
          dateStart: startDate,
          dateEnd: endDate,
          repeat: repeatPeriod,
          details: payment!.details.copyWith(
            name: title.isNotEmpty ? title : 'Без названия',
            note: note,
            money: amountValue.abs(),
            type: type,
            tax: taxRate, // Используем десятичную дробь для налога
            currency: CurrencyDataCommon.rub,
          ),
        ) ??
        Payment(
          paymentId: const Uuid().v4(),
          isEnabled: true,
          isDone: isDone,
          date: date,
          dateStart: startDate,
          dateEnd: endDate,
          repeat: repeatPeriod,
          details: PaymentDetails(
            name: title.isNotEmpty ? title : 'Без названия',
            note: note,
            money: amountValue.abs(),
            type: type,
            tax: taxRate, // Используем десятичную дробь для налога
            currency: CurrencyDataCommon.rub,
          ),
        );
  }

  @override
  List<Object?> get props => [
    payment,
    title,
    amount,
    note,
    tax,
    date,
    isDone,
    type,
    repeatPeriod,
    startDate,
    endDate,
    currentStep,
    showKeyboard,
    keyboardType,
    status,
    errorMessage,
  ];
}

/// Статус редактирования платежа
enum PaymentEditStatus {
  /// Начальное состояние
  initial,

  /// Загрузка
  loading,

  /// Успешное сохранение
  success,

  /// Ошибка
  failure,
}

/// Тип клавиатуры для ввода
enum KeyboardType {
  /// Клавиатура для ввода суммы платежа
  amount,

  /// Клавиатура для ввода процента налога
  tax,
}
