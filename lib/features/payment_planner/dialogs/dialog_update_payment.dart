import 'package:flutter/material.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      targetPayment != null
                          ? onDuplicate == null
                              ? 'Duplicate payment'
                              : 'Edit Payment'
                          : 'Create payment',
                    ),
                    if (paymentWhichTapped != null)
                      Text(
                        paymentWhichTapped.isParent
                            ? 'original'
                            : 'generated - you edit an original now',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      )
                  ],
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
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: inputDecoration.copyWith(labelText: 'Title'),
                    ),
                    const Divider(),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Money',
                        icon: Icon(Icons.attach_money),
                        iconColor: AppColorTokens.brandColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<PaymentType>(
                      selected: {type},
                      segments: [
                        ButtonSegment(
                          value: PaymentType.expense,
                          label: const Text('Expense'),
                        ),
                        ButtonSegment(
                          value: PaymentType.income,
                          label: const Text('Income'),
                        ),
                      ],
                      onSelectionChanged: (paymentTypes) {
                        setState(() {
                          type = paymentTypes.first;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Row(
                      children: <Widget>[
                        Text(
                          'Payment date: ${date != null ? dateFormat.format(date!) : 'Not set'}',
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
                        Text('Enabled:'),
                        Switch(
                          value: isEnabled,
                          onChanged: (value) {
                            setState(() {
                              isEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Done:'),
                        Switch(
                          value: isDone,
                          onChanged: (value) {
                            setState(() {
                              isDone = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),
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
                              child: Text(
                                  value == DateTimeRepeat.noRepeat ? 'No repeat' : value.shortName),
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
                    if (targetPayment != null && paymentWhichTapped != null) ...[
                      const Divider(),
                      if (onDuplicate != null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onDuplicate();
                          },
                          child: Text('Duplicate'),
                        ),
                      if (onFixation != null && paymentWhichTapped.isRepeat)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onFixation();
                          },
                          child: paymentWhichTapped.isRepeatParent
                              ? Text('Fixate this payment')
                              : Text('Fixate original payment'),
                        ),
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
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColorTokens.positiveMoneyColor,
                ),
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
