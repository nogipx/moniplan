import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/goals/bloc/goals_cubit.dart';
import 'package:moniplan_app/features/goals/models/savings_goal.dart';
import 'package:moniplan_app/features/goals/usecases/compute_daily_allowance_usecase.dart';
import 'package:moniplan_app/features/planner/planner_bloc/_index.dart';
import 'package:moniplan_app/features/planner/usecases/_index.dart';
import 'package:moniplan_app/utils/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

/// Экран «Цели» — дневной лимит трат, чтобы оставить X к зарплате.
/// Считается по последнему периоду (после последней коррекции).
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({required this.plannerId, super.key});

  final String plannerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GoalsCubit(
        repo: AppDi.instance.getSavingsGoalsRepo(),
        plannerId: plannerId,
      ),
      child: const _GoalsView(),
    );
  }
}

class _GoalsView extends StatelessWidget {
  const _GoalsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Дневной лимит')),
      body: SafeArea(
        child: BlocBuilder<GoalsCubit, GoalsState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            final goal = state.goal;
            if (goal == null) {
              return _EmptyGoal(onSet: () => _openEditor(context, null));
            }

            final scope = _lastPeriodScope(context);
            final allowance = ComputeDailyAllowanceUseCase(
              series: scope.series,
              payments: scope.payments,
              today: DateTime.now(),
              goal: goal,
            ).call();

            return ListView(
              padding: const EdgeInsets.all(AppSpace.s16),
              children: [
                if (allowance != null) _AllowanceCard(allowance: allowance),
                const SizedBox(height: AppSpace.s16),
                _TargetTile(
                  goal: goal,
                  onEdit: () => _openEditor(context, goal),
                  onDelete: () => context.read<GoalsCubit>().remove(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, SavingsGoal? existing) {
    final cubit = context.read<GoalsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _GoalEditorSheet(existing: existing, onSave: cubit.save),
    );
  }
}

// --- last-period scope ------------------------------------------------------

class _Scope {
  const _Scope(this.series, this.payments);

  final List<BalancePoint> series;
  final List<Payment> payments;
}

_Scope _lastPeriodScope(BuildContext context) {
  final state = context.read<PlannerBloc>().state;
  final computed =
      state.maybeMap(budgetComputed: (s) => s, orElse: () => null);
  if (computed == null) {
    return const _Scope([], []);
  }
  final points = BuildBalanceSeriesUseCase(
    payments: computed.payments,
    initialBalance: computed.moneyFlow.initialBalance,
    dateStart: computed.dateStart,
    dateEnd: computed.dateEnd,
  ).call();
  final periods = SplitPeriodsByCorrectionUseCase(
    series: points,
    payments: computed.payments,
  ).call();
  final last = periods.isNotEmpty ? periods.last : null;
  final series = last != null
      ? points
          .where((p) => !p.date.dayBound.isBefore(last.start.dayBound))
          .toList()
      : points;
  return _Scope(series, computed.payments);
}

// --- allowance card ---------------------------------------------------------

class _AllowanceCard extends StatelessWidget {
  const _AllowanceCard({required this.allowance});

  final DailyAllowance allowance;

  @override
  Widget build(BuildContext context) {
    final a = allowance;
    final positive = !a.overspent;
    final accent = positive
        ? (context.ext<MoniplanExtraColors>()?.moneyPositive ??
            context.color.primary)
        : context.color.error;
    final df = DateFormat('d MMM', 'ru');
    final horizon = a.hasNextSalary
        ? 'до зарплаты ${df.format(a.nextSalaryDate!)} · ${a.daysUntilSalary} дн'
        : 'до конца периода · ${a.daysUntilSalary} дн';

    return Container(
      padding: const EdgeInsets.all(AppSpace.s16),
      decoration: BoxDecoration(
        color: context.color.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(AppRadius.r12),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            positive ? 'Можно тратить в день' : 'Перерасход',
            style: context.text.labelLarge?.copyWith(color: accent),
          ),
          const SizedBox(height: AppSpace.s4),
          Text(
            '${_money(a.perDay)} / день',
            style: context.text.displaySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpace.s4),
          Text(
            horizon,
            style: context.text.bodySmall
                ?.copyWith(color: context.color.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpace.s12),
          const Divider(height: 1),
          const SizedBox(height: AppSpace.s12),
          _row(context, 'Остаток сегодня', a.todayBalance),
          _row(context, 'Списания до ${df.format(a.bindingDate)}', -a.scheduledOutflows),
          _row(context, 'Оставить к зарплате', -a.target),
          const SizedBox(height: AppSpace.s4),
          const Divider(height: 1),
          const SizedBox(height: AppSpace.s4),
          _row(context, 'Свободно на ${a.daysUntilSalary} дн', a.free, bold: true),
          if (a.bindingBeyondSalary) ...[
            const SizedBox(height: AppSpace.s8),
            Text(
              'Учтён провал после ближайшей зарплаты — до ${df.format(a.bindingDate)}.',
              style: context.text.bodySmall
                  ?.copyWith(color: context.color.onSurfaceVariant),
            ),
          ],
          if (a.overspent) ...[
            const SizedBox(height: AppSpace.s8),
            Text(
              'Не хватает ${_money(-a.free)}. Чтобы уложиться в цель, '
              'сократи траты примерно на ${_money(-a.perDay)}/день.',
              style: context.text.bodySmall?.copyWith(color: context.color.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, num value, {bool bold = false}) {
    final style = context.text.bodyMedium?.copyWith(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.text.bodyMedium),
          Text(_money(value), style: style),
        ],
      ),
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({
    required this.goal,
    required this.onEdit,
    required this.onDelete,
  });

  final SavingsGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final value = goal.basis == GoalBasis.days
        ? '${goal.days} дней расходов'
        : _money(goal.amount);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s16,
        vertical: AppSpace.s12,
      ),
      decoration: BoxDecoration(
        color: context.color.surfaceContainerLow,
        borderRadius: const BorderRadius.all(AppRadius.r12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Цель',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.color.onSurfaceVariant)),
                Text('оставить $value к зарплате',
                    style: context.text.bodyLarge),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.color.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _EmptyGoal extends StatelessWidget {
  const _EmptyGoal({required this.onSet});

  final VoidCallback onSet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.savings_outlined,
                size: 48, color: context.color.onSurfaceVariant),
            const SizedBox(height: AppSpace.s12),
            Text('Начни копить прозрачно', style: context.text.titleMedium),
            const SizedBox(height: AppSpace.s4),
            Text(
              'Задай, сколько хочешь оставлять к каждой зарплате — покажу, '
              'сколько можно тратить в день.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall
                  ?.copyWith(color: context.color.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpace.s16),
            FilledButton.icon(
              onPressed: onSet,
              icon: const Icon(Icons.add),
              label: const Text('Задать цель'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- editor -----------------------------------------------------------------

class _GoalEditorSheet extends StatefulWidget {
  const _GoalEditorSheet({required this.onSave, this.existing});

  final SavingsGoal? existing;
  final void Function(SavingsGoal goal) onSave;

  @override
  State<_GoalEditorSheet> createState() => _GoalEditorSheetState();
}

class _GoalEditorSheetState extends State<_GoalEditorSheet> {
  late GoalBasis _basis;
  late final TextEditingController _amount;
  late final TextEditingController _days;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _basis = g?.basis ?? GoalBasis.amount;
    _amount = TextEditingController(
        text: (g?.amount ?? 0) == 0 ? '' : '${g?.amount}');
    _days =
        TextEditingController(text: (g?.days ?? 0) == 0 ? '' : '${g?.days}');
  }

  @override
  void dispose() {
    _amount.dispose();
    _days.dispose();
    super.dispose();
  }

  void _save() {
    final amount =
        num.tryParse(_amount.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
    final days = int.tryParse(_days.text.trim()) ?? 0;
    widget.onSave(SavingsGoal(
      id: widget.existing?.id ?? '',
      plannerId: widget.existing?.plannerId ?? '',
      type: SavingsGoalType.perPeriod,
      basis: _basis,
      amount: amount,
      days: days,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final daysBasis = _basis == GoalBasis.days;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpace.s16,
        right: AppSpace.s16,
        top: AppSpace.s16,
        bottom: AppSpace.s16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Оставлять к зарплате',
            style:
                context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpace.s12),
          Wrap(
            spacing: AppSpace.s8,
            children: [
              ChoiceChip(
                label: const Text('₽'),
                selected: _basis == GoalBasis.amount,
                onSelected: (_) => setState(() => _basis = GoalBasis.amount),
              ),
              ChoiceChip(
                label: const Text('дни расходов'),
                selected: _basis == GoalBasis.days,
                onSelected: (_) => setState(() => _basis = GoalBasis.days),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s12),
          TextField(
            controller: daysBasis ? _days : _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9 .,]')),
            ],
            decoration: InputDecoration(
              labelText: daysBasis ? 'N дней расходов' : 'Сумма, ₽',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}

// --- shared -----------------------------------------------------------------

String _money(num v) => '${NumberFormat.decimalPattern('ru').format(v.round())} ₽';
