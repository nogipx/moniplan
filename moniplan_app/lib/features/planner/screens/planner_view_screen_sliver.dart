import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/goals/models/savings_goal.dart';
import 'package:moniplan_app/features/goals/screens/goals_screen.dart';
import 'package:moniplan_app/features/goals/usecases/compute_daily_allowance_usecase.dart';
import 'package:moniplan_app/features/payment_edit/dialogs/dialog_update_payment.dart';
import 'package:moniplan_app/features/planner/planner_bloc/_index.dart';
import 'package:moniplan_app/features/planner/usecases/_index.dart';
import 'package:moniplan_app/features/savings/screens/savings_screen.dart';
import 'package:moniplan_app/features/savings/usecases/compute_savings_usecase.dart';
import 'package:moniplan_app/features/tags/screens/tags_summary_screen.dart';
import 'package:moniplan_app/features/vacation_pay/screens/vacation_pay_screen.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:rpc_dart/logger.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:uuid/uuid.dart';

import '../widgets/payment_search_delegate.dart';
import '../widgets/payments_sliver_list.dart';
import 'planner_stats_screen.dart';

String _money(num v) =>
    '${NumberFormat.decimalPattern('ru').format(v.round())} ₽';

class PlannerScreen extends StatelessWidget {
  final String plannerId;

  const PlannerScreen({required this.plannerId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return PlannerBloc(
          plannerId: plannerId,
          plannersRepo: AppDi.instance.getPlannersRepo(),
          paymentsRepo: AppDi.instance.getPaymentsRepo(),
          actualInfoRepo: AppDi.instance.getPlannerActualInfoRepo(),
        )..add(const PlannerEvent.computeBudget());
      },
      child: const _PlannerViewScreenSliver(),
    );
  }
}

class _PlannerViewScreenSliver extends StatefulWidget {
  const _PlannerViewScreenSliver();

  @override
  State<_PlannerViewScreenSliver> createState() => _PlannerViewScreenSliverState();
}

class _PlannerViewScreenSliverState extends State<_PlannerViewScreenSliver> {
  final _listController = ListController();
  final _scrollController = ScrollController();
  final _log = RpcLogger('PlannerViewScreen');

  bool _isFirstScrolled = false;

  /// Цель «оставить X к зарплате» — для дневного лимита в шапке.
  SavingsGoal? _savingsGoal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadGoal());
  }

  Future<void> _reloadGoal() async {
    if (!mounted) {
      return;
    }
    final plannerId = context.read<PlannerBloc>().plannerId;
    final goals =
        await AppDi.instance.getSavingsGoalsRepo().listByPlanner(plannerId);
    if (!mounted) {
      return;
    }
    setState(() => _savingsGoal = goals.isEmpty ? null : goals.first);
  }

  List<BalancePoint> _lastPeriodSeries(PlannerBudgetComputedState s) {
    final points = BuildBalanceSeriesUseCase(
      payments: s.payments,
      initialBalance: s.moneyFlow.initialBalance,
      dateStart: s.dateStart,
      dateEnd: s.dateEnd,
    ).call();
    final periods = SplitPeriodsByCorrectionUseCase(
      series: points,
      payments: s.payments,
    ).call();
    final last = periods.isNotEmpty ? periods.last : null;
    if (last == null) {
      return points;
    }
    return points
        .where((p) => !p.date.dayBound.isBefore(last.start.dayBound))
        .toList();
  }

  @override
  void dispose() {
    _log.debug('PlannerViewScreen: Освобождение ресурсов');

    // Получаем блок и вызываем метод обновления actualInfo
    try {
      final plannerBloc = context.read<PlannerBloc>();
      _log.debug(
        'PlannerViewScreen: Вызов saveActualInfo для планера ${plannerBloc.plannerId}',
      );
      plannerBloc.saveActualInfo();
    } on Object catch (e) {
      _log.debug('PlannerViewScreen: Ошибка при сохранении actualInfo: $e');
    }

    // Освобождаем ресурсы контроллеров
    _listController.dispose();
    _scrollController.dispose();

    _log.debug('PlannerViewScreen: Ресурсы освобождены');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlannerBloc, PlannerState>(
      listener: (context, state) {
        if (state is PlannerBudgetComputedState &&
            state.getPaymentsByDate.isNotEmpty &&
            !_isFirstScrolled) {
          setState(() {
            _isFirstScrolled = true;
          });
          _moveToDate(DateTime.now(), jump: true);
        }
      },
      builder: (context, state) {
        final dateStartRaw = state.mapOrNull(
          budgetComputed: (s) => s.dateStart,
        );
        final dateStartString = dateStartRaw != null
            ? DateFormat(plannerBoundDateFormat).format(dateStartRaw)
            : '';

        final dateEndRaw = state.mapOrNull(budgetComputed: (s) => s.dateEnd);
        final dateEndString = dateEndRaw != null
            ? DateFormat(plannerBoundDateFormat).format(dateEndRaw)
            : '';

        final today = DateTime.now().dayBound;
        final paymentsByDate = state.getPaymentsByDate;

        final computed = state.maybeMap(
          budgetComputed: (s) => s,
          orElse: () => null,
        );
        final nowDate = DateTime.now();
        SavingsSummary? savings;
        DailyAllowance? allowance;
        if (computed != null) {
          savings = ComputeSavingsUseCase(
            payments: computed.payments,
            today: nowDate,
          ).call();
          final goal = _savingsGoal;
          if (goal != null) {
            allowance = ComputeDailyAllowanceUseCase(
              series: _lastPeriodSeries(computed),
              payments: computed.payments,
              today: nowDate,
              goal: goal,
            ).call();
          }
        }
        final showSavings =
            savings != null && (savings.today != 0 || savings.deposits != 0);
        final summaryLine = _summaryLine(
          context,
          allowance,
          showSavings ? savings : null,
        );

        final titleWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$dateStartString - $dateEndString',
              style: context.text.titleLarge,
            ),
            if (summaryLine != null) summaryLine,
          ],
        );

        final appBar = AppBar(
          title: titleWidget,
          actions: [
            IconButton(
              tooltip: 'Поиск',
              icon: const Icon(Icons.search),
              onPressed: () => _openSearch(context),
            ),
          ],
        );

        return Scaffold(
          appBar: appBar,
          body: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpace.s100,
                            ),
                            sliver: PaymentsSliverList(
                              listController: _listController,
                              today: today,
                              budget: state.budget,
                              paymentsByDate: paymentsByDate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.color.surface,
                          context.color.surface.withValues(alpha: .7),
                          context.color.surface.withValues(alpha: 0),
                        ],
                        stops: const [0, .8, 1],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                    ),
                  ),
                ),
              ),
              // Bottom bar pinned to the safe area: Сегодня | + | Утилиты.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.today, size: 18),
                                label: const Text('Сегодня'),
                                onPressed: () => _moveToDate(DateTime.now()),
                              ),
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: () => updateDialog(context: context),
                            child: const Icon(Icons.add),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.more_horiz,
                                  size: 18,
                                ),
                                label: const Text('Ещё'),
                                onPressed: () => _showToolsSheet(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _moveToDate(DateTime date, {bool jump = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) {
      return;
    }
    final state = context.read<PlannerBloc>().state.getPaymentsByDate.getIndexOfDate(date);
    if (state == null || !_listController.isAttached) {
      return;
    }

    if (jump) {
      _listController.jumpToItem(
        index: state.index,
        alignment: state.alignment,
        scrollController: _scrollController,
      );
    } else {
      _listController.animateToItem(
        index: state.index,
        alignment: state.alignment,
        scrollController: _scrollController,
        duration: (estimatedDistance) => const Duration(milliseconds: 250),
        curve: (estimatedDistance) => Curves.fastLinearToSlowEaseIn,
      );
    }
  }

  Widget? _summaryLine(
    BuildContext context,
    DailyAllowance? allowance,
    SavingsSummary? savings,
  ) {
    if (allowance == null && savings == null) {
      return null;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (allowance != null)
          Text(
            'Лимит ${_money(allowance.perDay)}/день',
            style: context.text.bodySmall?.copyWith(
              color: allowance.overspent
                  ? context.color.error
                  : context.color.onSurfaceVariant,
            ),
          ),
        if (allowance != null && savings != null)
          Text('   ·   ', style: context.text.bodySmall),
        if (savings != null)
          Text(
            'Копилка ${_money(savings.today)}',
            style: context.text.bodySmall
                ?.copyWith(color: context.color.tertiary),
          ),
      ],
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final payments = context.read<PlannerBloc>().state.getPayments;
    final selected = await showSearch<Payment?>(
      context: context,
      delegate: PaymentSearchDelegate(payments: payments),
    );
    if (selected != null && mounted) {
      await _moveToDate(selected.date);
    }
  }

  void _showToolsSheet(BuildContext context) {
    final bloc = context.read<PlannerBloc>();
    final plannerId = bloc.plannerId;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpace.s16),
                child: Text('Ещё'),
              ),
              ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: const Text('Статистика'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: const PlannerStatsScreen(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sell_outlined),
                title: const Text('По меткам'),
                subtitle: const Text('Суммы по каждой метке'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: const TagsSummaryScreen(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.beach_access_outlined),
                title: const Text('Расчёт отпускных'),
                subtitle: const Text('Добавит выплаты в этот план'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VacationPayScreen(
                        targetPlannerId: plannerId,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.savings_outlined),
                title: const Text('Накопления'),
                subtitle: const Text('Копилка: отложить и снять'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: const SavingsScreen(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.speed),
                title: const Text('Дневной лимит'),
                subtitle: const Text('Сколько можно тратить в день'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: bloc,
                            child: GoalsScreen(plannerId: plannerId),
                          ),
                        ),
                      )
                      .then((_) {
                        if (mounted) {
                          _reloadGoal();
                        }
                      });
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Коррекция баланса'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showCorrectionDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCorrectionDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Коррекция баланса'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(hintText: 'Сумма'),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final amount = double.tryParse(controller.text);
                if (amount != null) {
                  _saveCorrectionPayment(amount);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _saveCorrectionPayment(double amount) {
    final plannerBloc = context.read<PlannerBloc>();
    final planner = plannerBloc.state.resultingPlanner;

    // Получаем валюту из первого платежа или используем дефолтную
    final currency = CurrencyData.create('RUB', 2, symbol: '₽');

    // Создаем платеж типа correction
    final payment = Payment(
      paymentId: const Uuid().v4(),
      plannerId: planner.id,
      date: DateTime.now(),
      isDone: true,
      details: PaymentDetails(
        name: 'Коррекция баланса',
        type: PaymentType.correction,
        currency: currency,
        money: amount,
      ),
    );

    // Сохраняем платеж и обновляем бюджет
    plannerBloc
      ..add(PlannerEvent.updatePayment(newPayment: payment, create: true))
      ..add(const PlannerEvent.computeBudget());
  }
}
