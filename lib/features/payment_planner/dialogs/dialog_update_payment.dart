import 'package:flutter/material.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:responsive_framework/responsive_framework.dart';

Future<void> showUpdatePaymentDialog({
  required BuildContext context,
  required Function(Payment) onSave,
  Function()? onDelete,
  Function()? onDuplicate,
  Function()? onFixation,
  Payment? paymentWhichTapped,
  Payment? targetPayment,
}) async {
  final TextEditingController titleController = TextEditingController(
    text: targetPayment?.details.name ?? '',
  );
  final TextEditingController amountController = TextEditingController(
    text: targetPayment?.details.money.toInt().toString() ?? '',
  );

  DateTime? date = targetPayment?.date;
  DateTime? startDate = targetPayment?.dateStart;
  DateTime? endDate = targetPayment?.dateEnd;
  bool isEnabled = targetPayment?.isEnabled ?? true;
  bool isDone = targetPayment?.isDone ?? false;
  DateTimeRepeat repeatPeriod = targetPayment?.repeat ?? DateTimeRepeat.noRepeat;
  PaymentType type = targetPayment?.details.type ?? PaymentType.expense;

  Future<void> selectPaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      date = picked;
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate) {
      endDate = picked;
    }
  }

  final dateFormat = DateFormat(plannerBoundDateFormat);
  final inputDecoration = InputDecoration(
    border: InputBorder.none,
  );

  final boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.all(
      width: .5,
    ),
  );

  Widget buildMoneySection(BuildContext context, StateSetter setState) {
    return Container(
      decoration: boxDecoration,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: inputDecoration.copyWith(
              labelText: 'Money',
              icon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<PaymentType>(
            selected: {type},
            segments: [
              ButtonSegment(
                value: PaymentType.expense,
                label: const Text('Expense'),
                icon: Icon(Icons.remove),
              ),
              ButtonSegment(
                value: PaymentType.income,
                label: const Text('Income'),
                icon: Icon(Icons.add),
              ),
            ],
            selectedIcon: Icon(
              type == PaymentType.expense ? Icons.remove : Icons.add,
            ),
            onSelectionChanged: (paymentTypes) {
              setState(() {
                type = paymentTypes.first;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildDateSection(BuildContext context, StateSetter setState) {
    return Container(
      decoration: boxDecoration,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Payment date: ',
                    ),
                    TextSpan(
                      text: date != null ? dateFormat.format(date!) : 'Not set',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  await selectPaymentDate(context);
                  setState(() {});
                },
              ),
            ],
          ),
          Row(
            children: [
              Text('Repeat: '),
              DropdownButton<DateTimeRepeat>(
                value: repeatPeriod,
                onChanged: (DateTimeRepeat? newValue) {
                  setState(() {
                    repeatPeriod = newValue!;
                  });
                },
                items: DateTimeRepeat.values
                    .map<DropdownMenuItem<DateTimeRepeat>>((DateTimeRepeat value) {
                  return DropdownMenuItem<DateTimeRepeat>(
                    value: value,
                    child: Text(value == DateTimeRepeat.noRepeat ? 'No repeat' : value.shortName),
                  );
                }).toList(),
              ),
            ],
          ),
          if (repeatPeriod != DateTimeRepeat.noRepeat) ...[
            Row(
              children: <Widget>[
                Text(
                  'End date: ${endDate != null ? dateFormat.format(endDate!) : 'Not set'}',
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    await selectEndDate(context);
                    setState(() {});
                  },
                ),
                Spacer(),
                if (endDate != null)
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () async {
                      setState(() {
                        endDate = null;
                      });
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildControls(BuildContext context, StateSetter setState) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isEnabled = !isEnabled;
              });
            },
            icon: Icon(
              Icons.power_settings_new_rounded,
              size: 22,
            ),
            label: Text(isEnabled ? 'Enabled' : 'Disabled'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isDone = !isDone;
              });
            },
            icon: Icon(
              Icons.done_rounded,
              size: 22,
            ),
            label: Text(isDone ? 'Completed' : 'Not completed'),
          ),
        ),
      ],
    );
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        textAlign: TextAlign.start,
                        targetPayment != null
                            ? onDuplicate == null
                                ? 'Duplicate payment'
                                : 'Edit Payment'
                            : 'Create payment',
                      ),
                      if (paymentWhichTapped != null)
                        Text(
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          paymentWhichTapped.isParent
                              ? paymentWhichTapped.isRepeat
                                  ? 'initial repeated payment'
                                  : 'regular'
                              : 'repeated payment generation \n— you edit an original now',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                        )
                    ],
                  ),
                ),
                if (targetPayment != null && onDelete != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                    child: Text('Delete'),
                  ),
              ],
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 8),
            content: SizedBox(
              width: ResponsiveBreakpoints.of(context).isDesktop
                  ? MediaQuery.of(context).size.width * .5
                  : MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: inputDecoration.copyWith(labelText: 'Title'),
                      autofocus: titleController.text.isEmpty,
                    ),
                    const SizedBox(height: 8),
                    buildMoneySection(context, setState),
                    const SizedBox(height: 8),
                    buildDateSection(context, setState),
                    const SizedBox(height: 16),
                    buildControls(context, setState),
                    const SizedBox(height: 24),
                    if (targetPayment != null && paymentWhichTapped != null) ...[
                      if (onDuplicate != null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDuplicate();
                          },
                          child: Text('Duplicate'),
                        ),
                      if (onFixation != null && paymentWhichTapped.isRepeat) ...[
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onFixation();
                          },
                          child: paymentWhichTapped.isRepeatParent
                              ? Text('Fixate this payment')
                              : Text('Fixate original payment'),
                        ),
                      ]
                    ],
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрываем диалог
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (date == null) {
                    return;
                  }
                  final newMoney = num.tryParse(amountController.text) ?? 0.0;
                  final newType = type;

                  final resultPayment = targetPayment ??
                      Payment(
                        paymentId: const Uuid().v4(),
                        details: PaymentDetails(
                          name: titleController.text,
                          type: newType,
                          currency: AppCurrencies.ru,
                        ),
                        date: date!,
                      );

                  final updated = resultPayment.copyWith(
                    isEnabled: isEnabled,
                    isDone: isDone,
                    date: date!,
                    dateStart: startDate,
                    dateEnd: endDate,
                    repeat: repeatPeriod,
                    details: resultPayment.details.copyWith(
                      name: titleController.text,
                      money: newMoney.abs(),
                      type: newType,
                    ),
                  );
                  onSave(updated); // Вызываем функцию сохранения
                  Navigator.of(context).pop(); // Закрываем диалог
                },
                child: Text(
                  targetPayment != null ? 'Save' : 'Create',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
