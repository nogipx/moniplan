import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/_common/_index.dart';
import 'package:moniplan_app/features/payment/_index.dart';
import 'package:moniplan_app/features/payment_edit/dialogs/dialog_update_payment.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:rpc_dart/logger.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:uuid/uuid.dart';

import '../widgets/payments_sliver_list.dart';

class PlannerScreen extends StatelessWidget {
  final String plannerId;

  const PlannerScreen({required this.plannerId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return PlannerBloc(
          plannerId: plannerId,
          paymentPlannerRepo: AppDi.instance.getPlannerRepo(),
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

  @override
  void dispose() {
    _log.debug('PlannerViewScreen: Освобождение ресурсов');

    // Получаем блок и вызываем метод обновления actualInfo
    try {
      final plannerBloc = context.read<PlannerBloc>();
      _log.debug('PlannerViewScreen: Вызов saveActualInfo для планера ${plannerBloc.plannerId}');
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
        final dateStartRaw = state.mapOrNull(budgetComputed: (s) => s.dateStart);
        final dateStartString = dateStartRaw != null
            ? DateFormat(plannerBoundDateFormat).format(dateStartRaw)
            : '';

        final dateEndRaw = state.mapOrNull(budgetComputed: (s) => s.dateEnd);
        final dateEndString = dateEndRaw != null
            ? DateFormat(plannerBoundDateFormat).format(dateEndRaw)
            : '';

        final titleWidget = Text(
          '$dateStartString - $dateEndString',
          style: context.text.displaySmall,
        );

        final today = DateTime.now().dayBound;
        final paymentsByDate = state.getPaymentsByDate;

        final plannerId = context.read<PlannerBloc>().plannerId;

        final appBar = AppBar(
          title: titleWidget,
          actions: [],
        );

        final fab = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: ElevatedButton(
                child: const Text('Сегодня'),
                onPressed: () {
                  _moveToDate(DateTime.now());
                },
              ),
            ),
            ExtendedAppFloatingButton(
              onLongPressed: () {
                _showCorrectionDialog(context);
              },
              onPressed: () {
                updateDialog(context: context, plannerRepo: AppDi.instance.getPlannerRepo());
              },
            ),
          ],
        );

        return Scaffold(
          floatingActionButton: fab,
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
                            padding: const EdgeInsets.only(bottom: AppSpace.s100),
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
                    child: SizedBox(width: MediaQuery.of(context).size.width, height: 100),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Сумма'),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
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
