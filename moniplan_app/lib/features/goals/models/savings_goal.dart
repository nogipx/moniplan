// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

/// Тип цели накоплений.
enum SavingsGoalType {
  /// Пол: держать баланс не ниже цели.
  floor,

  /// Накопление: откладывать сумму за каждый период поступлений.
  perPeriod,

  /// Цель к дате: накопить сумму к сроку.
  deadline,
}

/// Как задан размер цели.
enum GoalBasis {
  /// Фиксированная сумма в рублях.
  amount,

  /// N дней среднего расхода (масштабируется от трат).
  days,
}

/// Цель накоплений планера (spec: подсистема «Цели»).
@freezed
abstract class SavingsGoal with _$SavingsGoal {
  @JsonSerializable()
  const factory SavingsGoal({
    required String id,
    required String plannerId,
    required SavingsGoalType type,
    @Default('') String title,
    @Default(GoalBasis.amount) GoalBasis basis,

    /// Целевая сумма в рублях (для basis == amount и для цели к дате).
    @Default(0) num amount,

    /// Число дней среднего расхода (для basis == days).
    @Default(0) int days,

    /// Срок для цели типа [SavingsGoalType.deadline].
    DateTime? deadline,
  }) = _SavingsGoal;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalFromJson(json);
}
