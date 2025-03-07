import 'package:flutter/material.dart';
import 'package:moniplan_app/features/planner/calculator/_index.dart';

/// Цифровая клавиатура
class NumericKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;
  final Function(double) onQuickValuePressed;
  final ThemeData theme;
  final bool isDarkMode;

  /// Текущее состояние калькулятора
  final CalculatorState calculatorState;

  /// Список кнопок быстрого доступа для отображения в правой колонке
  final List<QuickButton>? quickButtons;

  /// Показывать ли колонку быстрых значений
  final bool showQuickButtons;

  const NumericKeypad({
    Key? key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.onQuickValuePressed,
    required this.theme,
    required this.isDarkMode,
    required this.calculatorState,
    this.quickButtons,
    this.showQuickButtons = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showQuickButtons || (quickButtons?.isEmpty ?? true)) {
      // Если колонка быстрых значений отключена или нет кнопок, показываем только цифровую клавиатуру
      return _buildNumericKeypad();
    }

    return Row(
      children: [
        // Основная цифровая клавиатура (3x4)
        Expanded(flex: 3, child: _buildNumericKeypad()),

        // Колонка быстрых значений справа (если включена)
        Expanded(flex: 1, child: Column(children: _buildQuickButtons())),
      ],
    );
  }

  /// Строит основную цифровую клавиатуру
  Widget _buildNumericKeypad() {
    return Column(
      children: [
        // Ряд с цифрами 7, 8, 9
        Expanded(
          child: Row(
            children: [_buildDigitButton('7'), _buildDigitButton('8'), _buildDigitButton('9')],
          ),
        ),
        // Ряд с цифрами 4, 5, 6
        Expanded(
          child: Row(
            children: [_buildDigitButton('4'), _buildDigitButton('5'), _buildDigitButton('6')],
          ),
        ),
        // Ряд с цифрами 1, 2, 3
        Expanded(
          child: Row(
            children: [_buildDigitButton('1'), _buildDigitButton('2'), _buildDigitButton('3')],
          ),
        ),
        // Ряд с 0, точкой и бэкспейсом
        Expanded(
          child: Row(
            children: [
              _buildDigitButton('.'),
              _buildDigitButton('0'),
              _buildFunctionButton(Icons.backspace_outlined, onBackspacePressed),
            ],
          ),
        ),
      ],
    );
  }

  /// Создает список кнопок быстрого доступа
  List<Widget> _buildQuickButtons() {
    // Используем переданные кнопки или создаем кнопки по умолчанию
    final buttons = quickButtons;

    if (buttons == null || buttons.isEmpty) {
      return [];
    }

    // Создаем виджеты для каждой кнопки
    return buttons.map((button) => Expanded(child: _buildQuickButton(button))).toList();
  }

  /// Кнопка быстрого доступа
  Widget _buildQuickButton(QuickButton button) {
    // Определяем цвета для кнопки из темы приложения
    final buttonColor = button.backgroundColor ?? theme.colorScheme.primary.withOpacity(0.15);
    final textColor = button.textColor ?? theme.colorScheme.primary;
    final borderColor = button.borderColor ?? theme.colorScheme.primary.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Используем пользовательский обработчик, если он есть, иначе используем стандартный
            if (button.onPressed != null) {
              button.onPressed!(button.value, calculatorState);
            } else {
              onQuickValuePressed(button.value);
            }
          },
          splashColor: theme.colorScheme.primary.withOpacity(0.3),
          highlightColor: theme.colorScheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
          child: Center(
            child:
                button.icon != null
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(button.icon, color: textColor, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          button.text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      button.text,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 18,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  /// Кнопка с цифрой
  Widget _buildDigitButton(String digit) {
    // Определяем цвета для кнопки из темы приложения с большим контрастом
    final buttonColor = theme.colorScheme.surfaceVariant.withOpacity(0.8);
    final textColor = theme.colorScheme.onSurfaceVariant;

    // Специальный стиль для точки
    final isDecimalPoint = digit == '.';

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1), width: 0.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onDigitPressed(digit),
            splashColor: theme.colorScheme.primary.withOpacity(0.2),
            highlightColor: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
            child: Center(
              child: Text(
                digit,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontSize: isDecimalPoint ? 36 : 30,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Функциональная кнопка (бэкспейс)
  Widget _buildFunctionButton(IconData icon, VoidCallback onTap) {
    // Определяем цвета для кнопки из темы приложения с большим контрастом
    final buttonColor = theme.colorScheme.primary.withOpacity(0.15);
    final iconColor = theme.colorScheme.primary;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 0.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: theme.colorScheme.primary.withOpacity(0.2),
            highlightColor: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
            child: Center(child: Icon(icon, color: iconColor, size: 28)),
          ),
        ),
      ),
    );
  }
}
