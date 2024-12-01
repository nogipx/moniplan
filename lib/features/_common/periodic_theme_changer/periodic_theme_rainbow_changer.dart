import 'package:flutter/material.dart';
import 'package:moniplan/_run/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

typedef RainbowSeedGenerator = int Function();

class PeriodicThemeRainbowChanger extends StatefulWidget {
  const PeriodicThemeRainbowChanger({
    super.key,
    required this.themeProvider,
    required this.builder,
    this.initialTheme,
    this.isEnabled = false,
    this.changePeriod,
    this.rainbowSeedGenerator,
  });

  final Widget Function(BuildContext, AppTheme?) builder;
  final AppTheme? initialTheme;
  final MoniplanThemeGeneratorRainbow themeProvider;

  final bool isEnabled;
  final Duration? changePeriod;

  final RainbowSeedGenerator? rainbowSeedGenerator;

  @override
  State<PeriodicThemeRainbowChanger> createState() => _PeriodicThemeChangerState();
}

class _PeriodicThemeChangerState extends State<PeriodicThemeRainbowChanger>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;

  static const _defaultPeriod = Duration(seconds: 10);

  // Флаг, определяющий, должна ли анимация проигрываться
  bool get _shouldAnimate => widget.isEnabled;

  AppTheme? _theme;
  int? _lastSeed;

  void _listenTheme() {
    if (widget.rainbowSeedGenerator == null) {
      final theme = widget.themeProvider(
        rainbowColor: generateRainbowColor(_animation.value),
      );

      setState(() {
        _theme = theme;
      });
    } else {
      final seed = widget.rainbowSeedGenerator?.call();
      if (seed == _lastSeed) {
        return;
      }

      final theme = widget.themeProvider(
        rainbowSeed: seed,
        rainbowColor:
            widget.rainbowSeedGenerator == null ? generateRainbowColor(_animation.value) : null,
      );

      setState(() {
        _lastSeed = seed;
        _theme = theme;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _theme = widget.initialTheme;

    if (_shouldAnimate) {
      final period = widget.changePeriod ?? _defaultPeriod;
      // Создаём и запускаем внутренний контроллер анимации
      _controller = AnimationController(
        duration: period,
        vsync: this,
      )
        ..repeat()
        ..addListener(_listenTheme);
      _animation = _controller!;
    } else {
      // Анимация отключена
      _animation = const AlwaysStoppedAnimation(0);
    }
  }

  @override
  void didUpdateWidget(covariant PeriodicThemeRainbowChanger oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isEnabled != widget.isEnabled) {
      if (widget.isEnabled) {
        // Анимация была отключена, теперь включена
        // Создаём и запускаем внутренний контроллер анимации
        _controller = AnimationController(
          duration: widget.changePeriod,
          vsync: this,
        )
          ..repeat()
          ..addListener(_listenTheme);
        _animation = _controller!;
      } else {
        // Анимация была включена, теперь отключена
        _controller?.removeListener(_listenTheme);
        _controller?.stop();
        _animation = const AlwaysStoppedAnimation(0);
      }
    } else if (_shouldAnimate) {
      // Если внешняя анимация стала null, создаём внутренний контроллер
      if (_controller == null) {
        _controller = AnimationController(
          duration: widget.changePeriod,
          vsync: this,
        )
          ..repeat()
          ..addListener(_listenTheme);
        _animation = _controller!;
      }
    }
  }

  @override
  void dispose() {
    // Освобождаем внутренний контроллер, если он был создан
    _controller?.removeListener(_listenTheme);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Если анимация не должна проигрываться, возвращаем только child
    if (!_shouldAnimate) {
      return widget.builder(context, widget.initialTheme);
    }

    final child = widget.builder(context, _theme);
    return child;
  }
}
