import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/features/vacation_pay/bloc/vacation_pay_cubit.dart';
import 'package:moniplan_payroll/moniplan_payroll.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';

/// "Отпускные" — vacation-pay tool (spec 7). Quick mode: produce, preview,
/// import into a chosen planner. Reads nothing about the existing plan.
class VacationPayScreen extends StatelessWidget {
  const VacationPayScreen({this.targetPlannerId, super.key});

  /// When provided, import goes directly into this planner (no chooser) and
  /// the screen pops back afterwards.
  final String? targetPlannerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VacationPayCubit(
        paymentsRepo: AppDi.instance.getPaymentsRepo(),
        targetPlannerId: targetPlannerId,
      ),
      child: const _VacationPayView(),
    );
  }
}

class _VacationPayView extends StatelessWidget {
  const _VacationPayView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отпускные')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.s16),
          children: const [
            _InputsCard(),
            SizedBox(height: AppSpace.s16),
            _PreviewSection(),
          ],
        ),
      ),
    );
  }
}

// --- inputs -----------------------------------------------------------------

class _InputsCard extends StatefulWidget {
  const _InputsCard();

  @override
  State<_InputsCard> createState() => _InputsCardState();
}

class _InputsCardState extends State<_InputsCard> {
  late final TextEditingController _gross;
  late final TextEditingController _ytd;
  late final TextEditingController _firstDay;
  late final TextEditingController _secondDay;
  late final TextEditingController _adjustment;

  @override
  void initState() {
    super.initState();
    final s = context.read<VacationPayCubit>().state;
    _gross = TextEditingController(text: _num(s.grossMonthly));
    _ytd = TextEditingController(text: _num(s.ytd));
    _firstDay = TextEditingController(text: '${s.firstHalfDay}');
    _secondDay = TextEditingController(text: '${s.secondHalfDay}');
    _adjustment = TextEditingController(text: _num(s.manualAdjustment));
  }

  @override
  void dispose() {
    _gross.dispose();
    _ytd.dispose();
    _firstDay.dispose();
    _secondDay.dispose();
    _adjustment.dispose();
    super.dispose();
  }

  static String _num(num v) => v == 0 ? '' : v.toString();

  static num _parseNum(String t) =>
      num.tryParse(t.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VacationPayCubit>();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Параметры', style: _sectionStyle(context)),
          const SizedBox(height: AppSpace.s12),
          _field(
            controller: _gross,
            label: 'Оклад (гросс), ₽ в месяц',
            onChanged: (t) => cubit.updateGross(_parseNum(t)),
          ),
          const SizedBox(height: AppSpace.s12),
          _field(
            controller: _ytd,
            label: 'Доход с начала года, ₽',
            hint: 'Сумма гросс-начислений с января. 0 — весь расчёт по 13%.',
            onChanged: (t) => cubit.updateYtd(_parseNum(t)),
          ),
          const SizedBox(height: AppSpace.s12),
          Row(
            children: [
              Expanded(
                child: _field(
                  controller: _firstDay,
                  label: 'Аванс, день',
                  onChanged: (t) =>
                      cubit.updatePaydays(first: int.tryParse(t.trim())),
                ),
              ),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: _field(
                  controller: _secondDay,
                  label: 'Зарплата, день',
                  onChanged: (t) =>
                      cubit.updatePaydays(second: int.tryParse(t.trim())),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s12),
          const _RangeField(),
          const SizedBox(height: AppSpace.s12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text('Дополнительно', style: context.text.bodyMedium),
            children: [
              _field(
                controller: _adjustment,
                label: 'Ручная поправка гросс отпускных, ₽',
                onChanged: (t) => cubit.updateManualAdjustment(_parseNum(t)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9 .,]')),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        helperMaxLines: 2,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _RangeField extends StatelessWidget {
  const _RangeField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacationPayCubit, VacationPayState>(
      buildWhen: (a, b) =>
          a.vacationStart != b.vacationStart || a.vacationEnd != b.vacationEnd,
      builder: (context, state) {
        return OutlinedButton.icon(
          icon: const Icon(Icons.date_range),
          label: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Отпуск: ${_fmtDate(state.vacationStart)} — '
              '${_fmtDate(state.vacationEnd)}',
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            alignment: Alignment.centerLeft,
          ),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDateRange: DateTimeRange(
                start: state.vacationStart,
                end: state.vacationEnd,
              ),
            );
            if (picked != null && context.mounted) {
              context
                  .read<VacationPayCubit>()
                  .updateRange(picked.start, picked.end);
            }
          },
        );
      },
    );
  }
}

// --- preview ----------------------------------------------------------------

class _PreviewSection extends StatelessWidget {
  const _PreviewSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacationPayCubit, VacationPayState>(
      builder: (context, state) {
        if (state.error != null) {
          return _Card(
            child: Row(
              children: [
                Icon(Icons.error_outline, color: context.color.error),
                const SizedBox(width: AppSpace.s12),
                Expanded(child: Text(state.error!)),
              ],
            ),
          );
        }
        final result = state.result;
        if (result == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AvgDailyCard(result: result, state: state),
            const SizedBox(height: AppSpace.s16),
            if (result.breakdown.warnings.isNotEmpty) ...[
              _WarningsCard(warnings: result.breakdown.warnings),
              const SizedBox(height: AppSpace.s16),
            ],
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Выплаты', style: _sectionStyle(context)),
                  const SizedBox(height: AppSpace.s8),
                  for (var i = 0; i < result.payments.length; i++)
                    _PaymentRow(
                      index: i,
                      payment: result.payments[i],
                      enabled: i < state.enabled.length && state.enabled[i],
                    ),
                  const Divider(),
                  _totalRow(context, state),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.s16),
            FilledButton.icon(
              icon: const Icon(Icons.playlist_add),
              onPressed: state.selectedCount == 0
                  ? null
                  : () => _chooseAndImport(context),
              label: Text('Добавить в план (${state.selectedCount})'),
            ),
            const SizedBox(height: AppSpace.s24),
          ],
        );
      },
    );
  }

  Widget _totalRow(BuildContext context, VacationPayState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Итого на руки (выбрано)', style: context.text.bodyLarge),
          Text(
            _money(state.selectedNet),
            style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseAndImport(BuildContext context) async {
    final cubit = context.read<VacationPayCubit>();

    // Launched from a planner: import straight there and pop back.
    final target = cubit.targetPlannerId;
    if (target != null) {
      final count = await cubit.import(target);
      showToast('Добавлено платежей: $count');
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final planners = await AppDi.instance.getPlannersRepo().list();
    if (!context.mounted) {
      return;
    }

    final plannerId = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpace.s16),
                child: Text('Выберите план'),
              ),
              if (planners.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpace.s16),
                  child: Text('Нет доступных планов'),
                ),
              for (final planner in planners)
                ListTile(
                  title: Text(planner.name.isEmpty ? planner.id : planner.name),
                  onTap: () => Navigator.of(sheetContext).pop(planner.id),
                ),
            ],
          ),
        );
      },
    );
    if (plannerId == null) {
      return;
    }

    final count = await cubit.import(plannerId);
    showToast('Добавлено платежей: $count');
  }
}

class _AvgDailyCard extends StatelessWidget {
  const _AvgDailyCard({required this.result, required this.state});

  final PayrollResult result;
  final VacationPayState state;

  @override
  Widget build(BuildContext context) {
    final b = result.breakdown;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Средний дневной', style: context.text.bodyLarge),
              Text(
                _money(b.avgDailyEarnings),
                style: context.text.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s4),
          Text(
            'Оклад ${_money(state.grossMonthly)} / 29.3'
            '${b.mrotFloorApplied ? '  (поднят до МРОТ)' : ''}',
            style: context.text.bodySmall
                ?.copyWith(color: context.color.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpace.s4),
          Text(
            'Оплачиваемых дней отпуска: ${b.payableVacationDays}',
            style: context.text.bodySmall
                ?.copyWith(color: context.color.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _WarningsCard extends StatelessWidget {
  const _WarningsCard({required this.warnings});

  final List<PayrollWarning> warnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.all(AppRadius.r12),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final w in warnings)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber, size: 18, color: Colors.amber),
                  const SizedBox(width: AppSpace.s8),
                  Expanded(child: Text(w.message, style: context.text.bodySmall)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.index,
    required this.payment,
    required this.enabled,
  });

  final int index;
  final ProducedPayment payment;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final crossedThreshold = payment.marginalRate > 0.13;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Checkbox(
              value: enabled,
              onChanged: (v) => context
                  .read<VacationPayCubit>()
                  .togglePayment(index, enabled: v ?? false),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_kindName(payment.kind), style: context.text.bodyMedium),
                Text(
                  '${_fmtDate(payment.date)} · гросс ${_money(payment.gross)}'
                  ' · НДФЛ ${_money(payment.ndfl)}',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.color.onSurfaceVariant),
                ),
                if (crossedThreshold)
                  Text(
                    'часть дохода облагается по '
                    '${(payment.marginalRate * 100).round()}%',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.color.tertiary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s8),
          Text(
            _money(payment.net),
            style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// --- shared bits ------------------------------------------------------------

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s16),
      decoration: BoxDecoration(
        color: context.color.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(AppRadius.r12),
      ),
      child: child,
    );
  }
}

TextStyle? _sectionStyle(BuildContext context) =>
    context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold);

String _kindName(ProducedPaymentKind kind) {
  switch (kind) {
    case ProducedPaymentKind.vacationPay:
      return 'Отпускные';
    case ProducedPaymentKind.firstHalfSalary:
      return 'Зарплата (первая половина)';
    case ProducedPaymentKind.secondHalfSalary:
      return 'Зарплата (вторая половина)';
    case ProducedPaymentKind.dismissalCompensation:
      return 'Компенсация при увольнении';
    case ProducedPaymentKind.latePaymentCompensation:
      return 'Компенсация за задержку';
  }
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String _money(num v) {
  final negative = v < 0;
  final fixed = v.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(intPart[i]);
  }
  return '${negative ? '-' : ''}$buffer,${parts[1]} ₽';
}
