import 'package:flutter/material.dart';
import 'package:moniplan_app/features/calculator/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Цифровая клавиатура
class NumericKeypad extends StatelessWidget {
  /// Функция для нажатия на цифру
  final Function(String) onDigitPressed;

  /// Функция для нажатия на бэкспейс
  final VoidCallback onBackspacePressed;

  /// Callback для сброса значения на изначальное
  final VoidCallback? onResetPressed;

  /// Функция для нажатия на кнопку сброса
  final VoidCallback? onClearPressed;

  /// Тема приложения
  final ThemeData theme;

  /// Является ли темная тема
  final bool isDarkMode;

  /// Текущее состояние калькулятора
  final CalculatorState calculatorState;

  /// Список кнопок быстрого доступа для отображения в правой колонке
  final List<QuickButton>? quickButtons;

  /// Показывать ли колонку быстрых значений
  final bool showQuickButtons;

  /// Находимся ли мы в режиме редактирования существующего платежа
  final bool isEditing;

  const NumericKeypad({
    required this.onDigitPressed,
    required this.onBackspacePressed,
    required this.theme,
    required this.isDarkMode,
    required this.calculatorState,
    this.quickButtons,
    this.showQuickButtons = true,
    this.isEditing = false,
    this.onResetPressed,
    this.onClearPressed,
    super.key,
  });

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
    return Builder(
      builder: (context) {
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
            // Ряд с кнопкой сброса, 0 и бэкспейсом
            Expanded(
              child: Row(
                children: [
                  _buildDigitButton('.'),
                  _buildDigitButton('0'),
                  _buildFunctionButton(
                    Icons.backspace_outlined,
                    onBackspacePressed,
                    buttonColor: context.color.tertiaryContainer.withValues(alpha: 0.2),
                    iconColor: context.color.onTertiaryContainer,
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
    return Builder(
      builder: (context) {
        // Определяем цвета для кнопки из темы приложения
        final buttonColor = button.backgroundColor ?? context.color.primary.withValues(alpha: 0.15);
        final textColor = button.textColor ?? context.color.primary;
        final borderColor = button.borderColor ?? context.color.primary.withValues(alpha: 0.3);

        return Container(
          margin: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
            boxShadow: [
              BoxShadow(
                color: context.theme.shadowColor.withValues(alpha: 0.1),
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
                button.onPressed!(calculatorState);
              },
              splashColor: buttonColor.withValues(alpha: 0.3),
              highlightColor: buttonColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
              child: Center(
                child:
                    button.icon != null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(button.icon, color: textColor, size: 20),
                            const SizedBox(height: 6),
                            Text(
                              button.text,
                              style: context.text.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          button.text,
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 18,
                          ),
                        ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Кнопка с цифрой
  Widget _buildDigitButton(String digit, {Color? buttonColor, Color? iconColor}) {
    return Expanded(
      child: Builder(
        builder: (context) {
          // Определяем цвета для кнопки из темы приложения с большим контрастом
          final effectiveButtonColor =
              buttonColor ?? context.color.tertiaryContainer.withValues(alpha: 0.2);
          final effectiveTextColor = iconColor ?? context.color.onTertiaryContainer;

          // Специальный стиль для точки
          final isDecimalPoint = digit == '.';
          return Container(
            margin: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: effectiveButtonColor,
              borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: context.theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(color: effectiveButtonColor.withValues(alpha: 0.1), width: 0.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onDigitPressed(digit),
                splashColor: effectiveButtonColor.withValues(alpha: 0.2),
                highlightColor: effectiveButtonColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
                child: Center(
                  child: Text(
                    digit,
                    style: context.text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: effectiveTextColor,
                      fontSize: isDecimalPoint ? 36 : 30,
                      letterSpacing: -0.5,
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

  /// Функциональная кнопка (бэкспейс)
  Widget _buildFunctionButton(
    IconData icon,
    VoidCallback onTap, {
    Color? buttonColor,
    Color? iconColor,
  }) {
    return Expanded(
      child: Builder(
        builder: (context) {
          // Определяем цвета для кнопки из темы приложения с большим контрастом
          final effectiveButtonColor = buttonColor;
          final effectiveIconColor = iconColor;
          return Container(
            margin: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: effectiveButtonColor,
              borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: context.theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: effectiveButtonColor?.withValues(alpha: 0.2) ?? Colors.transparent,
                width: 0.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                onLongPress: onClearPressed,
                splashColor: effectiveButtonColor?.withValues(alpha: 0.2),
                highlightColor: effectiveButtonColor?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KeyboardConstants.buttonBorderRadius),
                child: Center(child: Icon(icon, color: effectiveIconColor, size: 28)),
              ),
            ),
          );
        },
      ),
    );
  }
}
