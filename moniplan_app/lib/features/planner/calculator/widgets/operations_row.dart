import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/planner/calculator/calculator_bloc/calculator_bloc.dart';
import 'package:moniplan_app/features/planner/calculator/calculator_bloc/calculator_event.dart';
import 'package:moniplan_app/features/planner/calculator/calculator_bloc/calculator_operator.dart';

/// Ряд с операциями калькулятора
class OperationsRow extends StatelessWidget {
  final Function(String) onOperationPressed;
  final CalculatorOperator currentOperator;
  final ThemeData theme;
  final bool isDarkMode;

  const OperationsRow({
    required this.onOperationPressed,
    required this.currentOperator,
    required this.theme,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1), width: 0.5),
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildOperationButton(
            'C',
            onPressed: () {
              context.read<CalculatorBloc>().add(ClearPressed());
              HapticFeedback.mediumImpact();
            },
          ),
          _buildOperationButton(CalculatorOperator.divide.symbol),
          _buildOperationButton(CalculatorOperator.multiply.symbol),
          _buildOperationButton(CalculatorOperator.add.symbol),
          _buildOperationButton(CalculatorOperator.subtract.symbol),
        ],
      ),
    );
  }

  /// Кнопка операции
  Widget _buildOperationButton(String operation, {VoidCallback? onPressed}) {
    final isEquals = operation == '=';
    final isActive = isEquals || operation == currentOperator.symbol;
    final isClear = operation == 'C';

    Color textColor;
    Color backgroundColor;

    if (isClear) {
      textColor = theme.colorScheme.error;
      backgroundColor = theme.colorScheme.error.withOpacity(0.1);
    } else if (isActive) {
      textColor = theme.colorScheme.primary;
      backgroundColor = theme.colorScheme.primary.withOpacity(0.15);
    } else {
      textColor = theme.colorScheme.onSurfaceVariant;
      backgroundColor = theme.colorScheme.surface;
    }

    return Expanded(
      child: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              elevation: isActive ? 1 : 0,
              child: InkWell(
                onTap: () => onPressed != null ? onPressed() : onOperationPressed(operation),
                borderRadius: BorderRadius.circular(16),
                splashColor: theme.colorScheme.primary.withOpacity(0.2),
                highlightColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Center(
                  child: Text(
                    operation,
                    style: theme.textTheme.headlineSmall?.copyWith(
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
