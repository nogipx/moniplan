import 'package:flutter/material.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

import '../../../core/di_get_it/app_di.dart';
import '../models/financial_flow_analysis_settings.dart';
import '../widgets/financial_flow_period_selector.dart';
import '../widgets/financial_flow_detailed_analysis.dart';

/// Экран подробного анализа финансового потока
class FinancialFlowAnalysisScreen extends StatefulWidget {
  const FinancialFlowAnalysisScreen({
    super.key,
    required this.plannerId,
    this.initialSettings,
  });

  final String plannerId;
  final FinancialFlowAnalysisSettings? initialSettings;

  @override
  State<FinancialFlowAnalysisScreen> createState() =>
      _FinancialFlowAnalysisScreenState();
}

class _FinancialFlowAnalysisScreenState
    extends State<FinancialFlowAnalysisScreen> {
  late FinancialFlowAnalysisSettings _settings;
  FinancialFlowCalculation? _calculation;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.initialSettings != null) {
        _settings = widget.initialSettings!;
      } else {
        // Загружаем планировщик и создаем настройки по умолчанию
        final planner = await _loadPlanner();
        _settings = FinancialFlowAnalysisSettings.fromPlanner(planner);
      }

      await _performAnalysis();
    } catch (e) {
      setState(() {
        _error = 'Ошибка инициализации: $e';
        _isLoading = false;
      });
    }
  }

  Future<Planner> _loadPlanner() async {
    final plannerRepository = AppDi.instance.getPlannerRepo();
    final planner = await plannerRepository.getPlannerById(widget.plannerId);
    if (planner == null) {
      throw Exception('Планировщик не найден');
    }
    return planner;
  }

  Future<void> _performAnalysis() async {
    if (!_settings.isValid) {
      setState(() {
        _error = 'Некорректные настройки анализа';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Загружаем планировщик
      final planner = await _loadPlanner();

      // Создаем адаптер для интеграции с планировщиком
      final adapter = PaymentToFinancialInstrumentAdapter();

      // Создаем профиль финансового потока из планировщика
      final profile = adapter.createProfileFromPlanner(
        planner,
        calculationSettings: const CalculationSettings(
          includeOneTimeItems: true,
          includeCreditBalances: true,
          groupByCategories: true,
          roundAmounts: true,
          decimalPlaces: 0, // Для рублей без копеек
        ),
      );

      // Обновляем профиль с настройками пользователя
      final updatedProfile = profile.copyWith(
        calculationPeriod: _settings.toCalculationPeriod(),
        defaultCurrency:
            CurrencyDataCommon.rub, // Принудительно устанавливаем рубли
      );

      // Создаем сервис расчетов
      final calculationService = FinancialFlowCalculationServiceImpl();

      // Выполняем расчет
      final calculation = await calculationService.calculateFinancialFlow(
        updatedProfile,
      );

      setState(() {
        _calculation = calculation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка анализа: $e';
        _isLoading = false;
      });
    }
  }

  void _onSettingsChanged(FinancialFlowAnalysisSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    _performAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Анализ финансового потока'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorWidget();
    }

    return Column(
      children: [
        // Селектор настроек
        FinancialFlowPeriodSelector(
          settings: _settings,
          onSettingsChanged: _onSettingsChanged,
          isLoading: _isLoading,
        ),

        const Divider(height: 1),

        // Основной контент
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Анализируем данные...'),
          ],
        ),
      );
    }

    if (_calculation == null) {
      return const Center(child: Text('Нет данных для анализа'));
    }

    return FinancialFlowDetailedAnalysis(
      calculation: _calculation!,
      settings: _settings,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeSettings,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
