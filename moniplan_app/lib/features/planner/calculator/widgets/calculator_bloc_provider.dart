import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/planner/calculator/_index.dart';

/// Провайдер для CalculatorBloc, который проверяет наличие блока в контексте
/// и при необходимости создает новый
class CalculatorBlocProvider extends StatefulWidget {
  final Widget child;
  final TextEditingController controller;

  const CalculatorBlocProvider({Key? key, required this.child, required this.controller})
    : super(key: key);

  @override
  State<CalculatorBlocProvider> createState() => _CalculatorBlocProviderState();
}

class _CalculatorBlocProviderState extends State<CalculatorBlocProvider> {
  late CalculatorBloc _calculatorBloc;
  bool _isExternalBloc = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Проверяем, есть ли блок в контексте
    try {
      _calculatorBloc = BlocProvider.of<CalculatorBloc>(context);
      _isExternalBloc = true;
      print('Используем существующий CalculatorBloc из контекста');
    } catch (e) {
      // Если блока нет, создаем новый
      _calculatorBloc = CalculatorBloc(controller: widget.controller);

      // Инициализируем блок
      final initialValue = widget.controller.text;
      if (initialValue.isNotEmpty) {
        _calculatorBloc.add(SetInitialValue(initialValue));
      }

      print('Создан новый CalculatorBloc');
      _isExternalBloc = false;
    }
  }

  @override
  void dispose() {
    // Закрываем блок только если мы его создали
    if (!_isExternalBloc) {
      _calculatorBloc.close();
      print('Закрыт локальный CalculatorBloc');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Если блок уже есть в контексте, просто возвращаем дочерний виджет
    if (_isExternalBloc) {
      return widget.child;
    }

    // Иначе оборачиваем в BlocProvider
    return BlocProvider<CalculatorBloc>.value(value: _calculatorBloc, child: widget.child);
  }
}
