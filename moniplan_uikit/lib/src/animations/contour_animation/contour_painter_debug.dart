import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Художник для отрисовки полного градиента в дебаг режиме поверх оборачиваемого виджета.
///
/// Данный класс добавляет больше информации для дебага и полезных визуальных подсказок, таких как текущая позиция градиента,
/// направление движения, границы элемента, а также отображение прогресса и истории траектории движения.
class DebugGradientPainter extends CustomPainter {
  final double progress;

  DebugGradientPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Радиус скругления
    const radius = 10.0;

    // Создание замкнутого пути для дебаг режима
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(radius),
        ),
      );

    // Использование PathMetric для равномерного вычисления точки на пути
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) {
      return;
    }

    // Создание градиента для отображения текущего состояния анимации
    final angle = progress * 2 * math.pi; // Угол поворота градиента, синхронизированный с анимацией
    final Gradient gradient = SweepGradient(
      colors: const [Colors.yellowAccent, Colors.purpleAccent],
      stops: const [0.0, 1.0],
      transform: GradientRotation(angle), // Поворот градиента с учетом прогресса анимации
    );

    final bounds = path.getBounds(); // Определение границ пути для корректного наложения градиента
    final paint = Paint()
      ..shader = gradient.createShader(bounds) // Применение градиента
      ..strokeWidth = 2.0 // Ширина линии в режиме дебага
      ..style = PaintingStyle.stroke; // Стиль рисования — только обводка

    // Отрисовка полного градиента на канвасе
    canvas.drawPath(path, paint);
  }

  /// Функция для вычисления угла в зависимости от текущего прогресса анимации.
  double angleForProgress(double progress) {
    return progress * 2 * math.pi; // Конвертируем прогресс (0.0-1.0) в угол (0-2π)
  }

  @override
  bool shouldRepaint(covariant DebugGradientPainter oldDelegate) {
    // Перерисовываем только если изменяется значение прогресса
    return oldDelegate.progress != progress;
  }
}
