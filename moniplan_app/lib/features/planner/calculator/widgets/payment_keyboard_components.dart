import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/planner/calculator/_index.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

/// Заголовок клавиатуры с переключателем типа платежа
class KeyboardHeader extends StatelessWidget {
  final PaymentType paymentType;
  final ValueChanged<PaymentType> onPaymentTypeChanged;
  final ThemeData theme;

  const KeyboardHeader({
    Key? key,
    required this.paymentType,
    required this.onPaymentTypeChanged,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpense = paymentType == PaymentType.expense;
    final color = isExpense ? theme.colorScheme.error : theme.colorScheme.tertiary;
    final backgroundColor =
        isExpense
            ? theme.colorScheme.errorContainer.withOpacity(0.3)
            : theme.colorScheme.tertiaryContainer.withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KeyboardConstants.defaultPadding,
        vertical: KeyboardConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: color.withOpacity(0.2), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Переключатель типа платежа
          _buildPaymentTypeToggle(),

          // Заголовок
          Text(
            'Калькулятор',
            style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Переключатель типа платежа
  Widget _buildPaymentTypeToggle() {
    final isExpense = paymentType == PaymentType.expense;
    final color = isExpense ? theme.colorScheme.error : theme.colorScheme.tertiary;
    final backgroundColor =
        isExpense ? theme.colorScheme.errorContainer : theme.colorScheme.tertiaryContainer;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: () {
          // Переключаем тип платежа
          final newType = isExpense ? PaymentType.income : PaymentType.expense;
          onPaymentTypeChanged(newType);
          HapticFeedback.mediumImpact();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KeyboardConstants.defaultPadding,
            vertical: KeyboardConstants.smallPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isExpense ? Icons.arrow_upward : Icons.arrow_downward, size: 18, color: color),
              const SizedBox(width: KeyboardConstants.smallPadding),
              Text(
                isExpense ? 'Расход' : 'Доход',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: KeyboardConstants.smallPadding),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.swap_horiz, size: 14, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
