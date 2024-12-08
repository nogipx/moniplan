import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Виджет с анимацией контура.
///
/// Если [animation] не передан, виджет создаёт собственный [AnimationController].
/// Флаг [isAnimated] работает независимо от того, передана ли внешняя анимация,
/// и позволяет включать или отключать анимацию.
///
/// При использовании в списках рекомендуется передавать внешний [animation]
/// для оптимальной производительности.
class ContourAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool debugMode;
  final Animation<double>? animation;
  final bool isAnimated;

  /// Опциональный пейнтер для отрисовки дополнительных элементов (например, для отладки).
  final CustomPainter Function(double progress)? debugPainter;

  /// Настраиваемая ширина линии.
  final double strokeWidth;

  /// Настраиваемый цвет линии.
  final Color color;

  /// Настраиваемый стиль кончиков линии (например, круглый или квадратный).
  final StrokeCap strokeCap;

  /// Радиус скругления углов.
  final double cornerRadius;

  /// Длина видимой части линии в доле от общей длины периметра.
  final double visibleFraction;

  /// Время проигрывания анимации (используется только при отсутствии внешней анимации).
  final Duration duration;

  /// Параметры для изменения размера прямоугольника по каждой стороне в пикселях.
  final EdgeInsets edgeOffsets;

  /// Колбек для генерации цвета на основе текущего прогресса.
  final Color Function(double progress)? colorGenerator;

  /// Колбек для генерации ширины линии на основе текущего прогресса.
  final double Function(double progress)? strokeWidthGenerator;

  /// Колбек для генерации радиуса углов на основе текущего прогресса.
  final double Function(double progress)? cornerRadiusGenerator;

  /// Колбек для генерации длины видимой части линии на основе текущего прогресса.
  final double Function(double progress)? visibleFractionGenerator;

  const ContourAnimationWidget({
    required this.child,
    this.animation,
    this.isAnimated = true,
    this.debugMode = false,
    this.debugPainter,
    this.strokeWidth = 6.0,
    this.color = Colors.white,
    this.strokeCap = StrokeCap.round,
    this.cornerRadius = 10.0,
    this.visibleFraction = 1 / 12,
    this.duration = const Duration(seconds: 10),
    this.edgeOffsets = EdgeInsets.zero,
    this.colorGenerator,
    this.strokeWidthGenerator,
    this.cornerRadiusGenerator,
    this.visibleFractionGenerator,
    super.key,
  });

  @override
  _ContourAnimationWidgetState createState() => _ContourAnimationWidgetState();
}

class _ContourAnimationWidgetState extends State<ContourAnimationWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;

  // Флаг, определяющий, должна ли анимация проигрываться
  bool get _shouldAnimate => widget.isAnimated;

  @override
  void initState() {
    super.initState();

    if (_shouldAnimate) {
      if (widget.animation != null) {
        // Используем внешний контроллер анимации
        _animation = widget.animation!;
      } else {
        // Создаём и запускаем внутренний контроллер анимации
        _controller = AnimationController(
          duration: widget.duration,
          vsync: this,
        )..repeat();
        _animation = _controller!;
      }
    } else {
      // Анимация отключена
      _animation = const AlwaysStoppedAnimation(-1);
    }
  }

  @override
  void didUpdateWidget(covariant ContourAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Обновляем виджет при изменении режима отладки
    if (oldWidget.debugMode != widget.debugMode) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Освобождаем внутренний контроллер, если он был создан
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Если анимация не должна проигрываться, возвращаем только child
    if (!_shouldAnimate) {
      return widget.child;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: ContourAnimationPainter(
              _animation.value,
              enabled: _animation.value >= 0,
              debugPainter: widget.debugMode && widget.debugPainter != null
                  ? widget.debugPainter!(_animation.value)
                  : null,
              strokeWidth: widget.strokeWidthGenerator != null
                  ? widget.strokeWidthGenerator!(_animation.value)
                  : widget.strokeWidth,
              color: widget.colorGenerator != null
                  ? widget.colorGenerator!(_animation.value)
                  : widget.color,
              strokeCap: widget.strokeCap,
              cornerRadius: widget.cornerRadiusGenerator != null
                  ? widget.cornerRadiusGenerator!(_animation.value)
                  : widget.cornerRadius,
              visibleFraction: widget.visibleFractionGenerator != null
                  ? widget.visibleFractionGenerator!(_animation.value)
                  : widget.visibleFraction,
              edgeOffsets: widget.edgeOffsets,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Кастомный художник для рисования анимации вдоль контура виджета.
///
/// Этот класс отвечает за отрисовку анимированной линии,
/// которая перемещается по периметру прямоугольника с закругленными углами.
/// Он может быть использован для создания визуального эффекта обводки или подсветки виджета.
class ContourAnimationPainter extends CustomPainter {
  /// Текущее значение прогресса анимации (от 0.0 до 1.0).
  final double progress;

  /// Опциональный пейнтер для отрисовки дополнительных элементов (например, для отладки).
  final CustomPainter? debugPainter;

  /// Настраиваемая ширина линии.
  final double strokeWidth;

  /// Настраиваемый цвет линии.
  final Color color;

  /// Настраиваемый стиль кончиков линии (например, круглый или квадратный).
  final StrokeCap strokeCap;

  /// Радиус скругления углов.
  final double cornerRadius;

  /// Длина видимой части линии в доле от общей длины периметра.
  final double visibleFraction;

  /// Параметры для изменения размера прямоугольника по каждой стороне в пикселях.
  final EdgeInsets edgeOffsets;

  /// Параметр для включения/отключения отрисовки.
  final bool enabled;

  /// Конструктор класса [ContourAnimationPainter].
  ///
  /// Принимает [progress] для управления анимацией и дополнительные параметры для кастомизации внешнего вида.
  const ContourAnimationPainter(
    this.progress, {
    this.enabled = true,
    this.debugPainter,
    this.strokeWidth = 6.0,
    this.color = Colors.white,
    this.strokeCap = StrokeCap.round,
    this.cornerRadius = 10.0,
    this.visibleFraction = 1 / 12,
    this.edgeOffsets = EdgeInsets.zero,
  }) : assert(progress >= 0 && progress <= 1, 'Progress should be in range from 0 to 1');

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) {
      return;
    }

    // Получаем координаты прямоугольника с учетом edgeOffsets.
    final left = edgeOffsets.left;
    final top = edgeOffsets.top;
    final right = size.width - edgeOffsets.right;
    final bottom = size.height - edgeOffsets.bottom;

    // Вычисляем общую длину периметра прямоугольника с учетом скругленных углов.
    //
    // Формула состоит из:
    // - суммарной длины сторон без скругленных углов: 2 * ((right - left) + (bottom - top) - 4 * cornerRadius)
    // - длины дуг скругленных углов: 2 * π * cornerRadius
    final perimeterLength =
        2 * ((right - left) + (bottom - top) - 4 * cornerRadius) + 2 * math.pi * cornerRadius;

    // Определяем длину видимого сегмента линии.
    final visibleLength = perimeterLength * visibleFraction;

    // Вычисляем текущую позицию начала видимого сегмента на периметре.
    //
    // Умножаем [progress] на общую длину периметра и используем модуль, чтобы зациклить движение.
    final currentProgress = (progress * perimeterLength) % perimeterLength;

    // Создаем прямоугольник с закругленными углами, по которому будет двигаться линия.
    final roundedRect = RRect.fromLTRBR(
      left, // Координата левой границы.
      top, // Координата верхней границы.
      right, // Координата правой границы.
      bottom, // Координата нижней границы.
      Radius.circular(cornerRadius), // Радиус скругления углов.
    );

    // Создаем путь на основе прямоугольника с закругленными углами.
    final path = Path()..addRRect(roundedRect);

    // Получаем метрики пути для точного позиционирования на нем.
    //
    // Используем итератор для эффективного доступа без создания списка.
    final iterator = path.computeMetrics().iterator;

    // Проверяем, содержит ли путь какие-либо метрики.
    if (!iterator.moveNext()) {
      return; // Если нет, выходим из метода.
    }

    // Получаем первую метрику пути.
    final pathMetric = iterator.current;

    // Определяем начальную и конечную точки видимого сегмента на пути.
    final start = currentProgress; // Начальная точка сегмента.
    final end = start + visibleLength; // Конечная точка сегмента.

    // Инициализируем переменную для хранения извлеченного сегмента пути.
    Path extractPath;

    // Проверяем, не превышает ли конец сегмента общую длину пути.
    if (end <= pathMetric.length) {
      // Если конец сегмента находится внутри длины пути,
      // извлекаем сегмент напрямую.
      extractPath = pathMetric.extractPath(
        start,
        end,
      );
    } else {
      // Если конец сегмента выходит за пределы пути,
      // необходимо объединить два сегмента:
      // 1. От начальной точки до конца пути.
      // 2. От начала пути до оставшейся части сегмента.
      extractPath = Path()
        // Добавляем первый сегмент от [start] до конца пути.
        ..addPath(
          pathMetric.extractPath(
            start,
            pathMetric.length,
          ),
          Offset.zero, // Смещение не требуется.
        )
        // Добавляем второй сегмент от начала пути до [(end - длина пути)].
        ..addPath(
          pathMetric.extractPath(
            0,
            end - pathMetric.length,
          ),
          Offset.zero,
        );
    }

    // Статический объект [Paint] для настройки кисти рисования.
    final paint = Paint()
      ..strokeWidth = strokeWidth // Настраиваемая ширина линии.
      ..color = color // Настраиваемый цвет линии.
      ..style = PaintingStyle.stroke // Указываем, что рисуем только обводку.
      ..strokeCap = strokeCap; // Настраиваемые концы линии.

    // Рисуем извлеченный сегмент пути на холсте с использованием настроенной кисти.
    canvas.drawPath(extractPath, paint);

    // Если предоставлен [debugPainter], вызываем его метод paint для дополнительной отрисовки.
    debugPainter?.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant ContourAnimationPainter oldDelegate) {
    // Указываем, что необходимо перерисовать, если изменился [progress] или любой из параметров кастомизации.
    return oldDelegate.enabled != enabled ||
        oldDelegate.progress != progress ||
        oldDelegate.debugPainter != debugPainter ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.strokeCap != strokeCap ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.visibleFraction != visibleFraction ||
        oldDelegate.edgeOffsets != edgeOffsets;
  }
}
