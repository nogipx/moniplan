import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/calculator/calculator_bloc/calculator_bloc.dart';
import 'package:moniplan_app/features/calculator/calculator_bloc/calculator_event.dart';
import 'package:moniplan_app/features/calculator/calculator_bloc/calculator_operator.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Ряд с операциями калькулятора
class OperationsRow extends StatelessWidget {
  final CalculatorOperator currentOperator;
  final ThemeData theme;
  final bool isDarkMode;

  const OperationsRow({
    required this.currentOperator,
    required this.theme,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: Row(
        children: [
          _buildOperationButton(
            CalculatorOperator.reset.symbol,
            onPressed: () {
              context.read<CalculatorBloc>().add(ResetPressed());
              HapticFeedback.mediumImpact();
            },
          ),
          _buildOperationButton(
            CalculatorOperator.divide.symbol,
            onPressed: () {
              context.read<CalculatorBloc>().add(
                OperationPressed(CalculatorOperator.divide.symbol),
              );
              HapticFeedback.lightImpact();
            },
          ),
          _buildOperationButton(
            CalculatorOperator.multiply.symbol,
            onPressed: () {
              context.read<CalculatorBloc>().add(
                OperationPressed(CalculatorOperator.multiply.symbol),
              );
              HapticFeedback.lightImpact();
            },
          ),
          _buildOperationButton(
            CalculatorOperator.add.symbol,
            onPressed: () {
              context.read<CalculatorBloc>().add(OperationPressed(CalculatorOperator.add.symbol));
              HapticFeedback.lightImpact();
            },
          ),
          _buildOperationButton(
            CalculatorOperator.subtract.symbol,
            onPressed: () {
              context.read<CalculatorBloc>().add(
                OperationPressed(CalculatorOperator.subtract.symbol),
              );
              HapticFeedback.lightImpact();
            },
          ),
          _buildOperationButton(
            CalculatorOperator.equals.symbol,
            onPressed: () {
              context.read<CalculatorBloc>().add(EqualsPressed());
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  /// Кнопка операции
  Widget _buildOperationButton(String operation, {VoidCallback? onPressed}) {
    final isEquals = operation == CalculatorOperator.equals.symbol;
    final isActive = isEquals || operation == currentOperator.symbol;
    final isReset = operation == CalculatorOperator.reset.symbol;

    return Expanded(
      child: Builder(
        builder: (context) {
          Color textColor;
          Color backgroundColor;

          if (isReset) {
            textColor = context.color.onTertiaryContainer;
            backgroundColor = Colors.transparent;
          } else if (isEquals) {
            textColor = context.color.onTertiaryContainer;
            backgroundColor = context.color.tertiaryContainer.withValues(alpha: 0.2);
          } else if (isActive) {
            textColor = context.color.primary;
            backgroundColor = context.color.primary.withValues(alpha: 0.15);
          } else {
            textColor = context.color.onSurfaceVariant;
            backgroundColor = context.color.surface;
          }

          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              elevation: 0,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(16),
                splashColor: backgroundColor.withValues(alpha: 0.2),
                highlightColor: backgroundColor.withValues(alpha: 0.1),
                child: Center(
                  child: Text(
                    operation,
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: textColor,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
