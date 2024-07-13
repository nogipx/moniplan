import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';

Future<void> showUpdatePaymentDialog({
  required BuildContext context,
  required Function(Payment) onSave,
  Function()? onDelete,
  Payment? payment,
}) async {
  final TextEditingController titleController = TextEditingController(
    text: payment?.details.name ?? '',
  );
  final TextEditingController amountController = TextEditingController(
    text: payment?.details.money.toString() ?? '',
  );

  DateTime? date = payment?.date;
  DateTime? startDate = payment?.dateStart;
  DateTime? endDate = payment?.dateEnd;
  bool isEnabled = payment?.isEnabled ?? true;
  bool isDone = payment?.isDone ?? false;
  DateTimeRepeat repeatPeriod = payment?.repeat ?? DateTimeRepeat.noRepeat;
  PaymentType type = payment?.details.type ?? PaymentType.expense;

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

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      startDate = picked;
      if (endDate != null && startDate!.isAfter(endDate!)) {
        endDate = startDate;
      }
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
              children: [
                Text(payment != null ? 'Edit Payment' : 'Create payment'),
                if (onDelete != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                    child: Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
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
                    decoration: inputDecoration.copyWith(labelText: 'Money'),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<PaymentType>(
                        title: const Text('Expense'),
                        value: PaymentType.expense,
                        groupValue: type,
                        onChanged: (PaymentType? value) {
                          setState(() {
                            type = value!;
                          });
                        },
                      ),
                      RadioListTile<PaymentType>(
                        title: const Text('Income'),
                        value: PaymentType.income,
                        groupValue: type,
                        onChanged: (PaymentType? value) {
                          setState(() {
                            type = value!;
                          });
                        },
                      )
                    ],
                  ),
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
                          'Start date: ${startDate != null ? dateFormat.format(startDate!) : 'Not set'}',
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            await selectStartDate(context);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
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
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрываем диалог
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (date == null) {
                    return;
                  }
                  final newMoney = num.tryParse(amountController.text) ?? 0.0;
                  final newType = type;

                  final targetPayment = payment ??
                      Payment(
                        paymentId: const Uuid().v4(),
                        details: PaymentDetails(
                          name: titleController.text,
                          type: newType,
                          currency: AppCurrencies.ru,
                        ),
                        date: date!,
                      );

                  final updated = targetPayment.copyWith(
                    isEnabled: isEnabled,
                    isDone: isDone,
                    date: date!,
                    dateStart: startDate,
                    dateEnd: endDate,
                    repeat: repeatPeriod,
                    details: targetPayment.details.copyWith(
                      name: titleController.text,
                      money: newMoney.abs(),
                      type: newType,
                    ),
                  );
                  onSave(updated); // Вызываем функцию сохранения
                  Navigator.of(context).pop(); // Закрываем диалог
                },
                child: Text(payment != null ? 'Save' : 'Create'),
              ),
            ],
          );
        },
      );
    },
  );
}
