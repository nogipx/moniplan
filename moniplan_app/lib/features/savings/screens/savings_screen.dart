import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/planner/planner_bloc/_index.dart';
import 'package:moniplan_app/features/savings/usecases/compute_savings_usecase.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:uuid/uuid.dart';

/// Экран «Накопления» — копилка планера: накоплено сегодня + прогноз, и
/// действия «Отложить» / «Снять». Требует PlannerBloc в контексте.
class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Накопления')),
      body: SafeArea(
        child: BlocBuilder<PlannerBloc, PlannerState>(
          builder: (context, state) {
            final payments = state.getPayments;
            final summary = ComputeSavingsUseCase(
              payments: payments,
              today: DateTime.now(),
            ).call();

            return ListView(
              padding: const EdgeInsets.all(AppSpace.s16),
              children: [
                _SummaryCard(summary: summary),
                const SizedBox(height: AppSpace.s16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.savings_outlined),
                        label: const Text('Отложить'),
                        onPressed: () => _add(context, deposit: true),
                      ),
                    ),
                    const SizedBox(width: AppSpace.s12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.output),
                        label: const Text('Снять'),
                        onPressed: () => _add(context, deposit: false),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, {required bool deposit}) async {
    final bloc = context.read<PlannerBloc>();
    final result = await showModalBottomSheet<_SavingsInput>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SavingsDialog(deposit: deposit),
    );
    if (result == null) {
      return;
    }

    final payment = Payment(
      paymentId: const Uuid().v4(),
      date: result.date,
      repeat: result.monthly ? DateTimeRepeat.month : DateTimeRepeat.noRepeat,
      dateStart: result.monthly ? result.date : null,
      details: PaymentDetails(
        name: deposit ? 'Накопление' : 'Снятие из накоплений',
        type: deposit ? PaymentType.savings : PaymentType.savingsWithdraw,
        currency: CurrencyDataCommon.rub,
        money: result.amount,
      ),
    );
    bloc.add(PlannerEvent.updatePayment(newPayment: payment, create: true));
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final SavingsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s16),
      decoration: BoxDecoration(
        color: context.color.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(AppRadius.r12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Накоплено сегодня',
              style: context.text.labelLarge
                  ?.copyWith(color: context.color.tertiary)),
          const SizedBox(height: AppSpace.s4),
          Text(
            _money(summary.today),
            style: context.text.displaySmall?.copyWith(
              color: context.color.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpace.s12),
          const Divider(height: 1),
          const SizedBox(height: AppSpace.s12),
          _row(context, 'Отложено (факт)', summary.deposits),
          _row(context, 'Снято (факт)', -summary.withdrawals),
          const SizedBox(height: AppSpace.s4),
          _row(context, 'Прогноз к концу плана', summary.projected, bold: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, num value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.text.bodyMedium),
          Text(
            _money(value),
            style: context.text.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsInput {
  const _SavingsInput(this.amount, this.date, {required this.monthly});

  final num amount;
  final DateTime date;
  final bool monthly;
}

class _SavingsDialog extends StatefulWidget {
  const _SavingsDialog({required this.deposit});

  final bool deposit;

  @override
  State<_SavingsDialog> createState() => _SavingsDialogState();
}

class _SavingsDialogState extends State<_SavingsDialog> {
  final _amount = TextEditingController();
  late DateTime _date;
  bool _monthly = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final amount =
        num.tryParse(_amount.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop(_SavingsInput(amount, _date, monthly: _monthly));
  }

  @override
  Widget build(BuildContext context) {
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
            widget.deposit ? 'Отложить в накопления' : 'Снять из накоплений',
            style:
                context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpace.s12),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9 .,]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Сумма, ₽',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSpace.s12),
          OutlinedButton.icon(
            icon: const Icon(Icons.event),
            label: Text('Дата: ${DateFormat('d MMM y', 'ru').format(_date)}'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              alignment: Alignment.centerLeft,
            ),
            onPressed: _pickDate,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ежемесячно'),
            value: _monthly,
            onChanged: (v) => setState(() => _monthly = v),
          ),
          const SizedBox(height: AppSpace.s8),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }
}

String _money(num v) => '${NumberFormat.decimalPattern('ru').format(v.round())} ₽';
