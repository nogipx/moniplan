import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

import '../bloc/_index.dart';

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
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          _OperationButton(
            operator: CalculatorOperator.reset,
            currentOperator: currentOperator,
            onPressed: () {
              context.read<CalculatorBloc>().add(ResetPressed());
              HapticFeedback.mediumImpact();
            },
          ),
          _OperationButton(
            operator: CalculatorOperator.divide,
            currentOperator: currentOperator,
            onPressed: () {
              context.read<CalculatorBloc>().add(
                OperationPressed(CalculatorOperator.divide.symbol),
              );
              HapticFeedback.lightImpact();
            },
          ),
          _OperationButton(
            operator: CalculatorOperator.multiply,
            currentOperator: currentOperator,
            onPressed: () {
              context.read<CalculatorBloc>().add(
                OperationPressed(CalculatorOperator.multiply.symbol),
              );
              HapticFeedback.lightImpact();
            },
          ),
          _OperationButton(
            operator: CalculatorOperator.add,
            currentOperator: currentOperator,
            onPressed: () {
              context.read<CalculatorBloc>().add(OperationPressed(CalculatorOperator.add.symbol));
              HapticFeedback.lightImpact();
            },
          ),
          _OperationButton(
            operator: CalculatorOperator.subtract,
            currentOperator: currentOperator,
            onPressed: () {
              context.read<CalculatorBloc>().add(
                OperationPressed(CalculatorOperator.subtract.symbol),
              );
              HapticFeedback.lightImpact();
            },
          ),
          _OperationButton(
            operator: CalculatorOperator.equals,
            currentOperator: currentOperator,
            onPressed: () {
              context.read<CalculatorBloc>().add(EqualsPressed());
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }
}

class _OperationButton extends StatelessWidget {
  final CalculatorOperator operator;
  final CalculatorOperator currentOperator;
  final VoidCallback? onPressed;

  const _OperationButton({required this.operator, required this.currentOperator, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final operatorSymbol = operator.symbol;
    final isEquals = operatorSymbol == CalculatorOperator.equals.symbol;
    final isActive = isEquals || operatorSymbol == currentOperator.symbol;
    final isReset = operatorSymbol == CalculatorOperator.reset.symbol;

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
            padding: const EdgeInsets.all(6),
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(16),
                splashColor: backgroundColor.withValues(alpha: 0.2),
                highlightColor: backgroundColor.withValues(alpha: 0.1),
                child: Center(
                  child: Text(
                    operatorSymbol,
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
