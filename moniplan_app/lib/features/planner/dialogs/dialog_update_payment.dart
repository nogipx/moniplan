// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';
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
  final TextEditingController taxController = TextEditingController(
    text: ((targetPayment?.details.tax ?? 0) * 100).toInt().toString(),
  );

  DateTime? date = targetPayment?.date ?? DateTime.now();
  DateTime? startDate = targetPayment?.dateStart;
  DateTime? endDate = targetPayment?.dateEnd;
  bool isEnabled = targetPayment?.isEnabled ?? true;
  bool isDone = targetPayment?.isDone ?? false;
  DateTimeRepeat repeatPeriod = targetPayment?.repeat ?? DateTimeRepeat.noRepeat;
  PaymentType type = targetPayment?.details.type ?? PaymentType.expense;

  Future<void> selectPaymentDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        date = picked;
      });
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
          if (type == PaymentType.income)
            TextField(
              controller: taxController,
              keyboardType: TextInputType.number,
              decoration: inputDecoration.copyWith(
                labelText: 'Tax',
                icon: Icon(Icons.percent_rounded),
              ),
            ),
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
            style: SegmentedButton.styleFrom(
              backgroundColor: context.color.surfaceContainerLow,
              selectedBackgroundColor: context.color.surfaceContainerLow,
              foregroundColor: context.color.onSurfaceVariant,
              selectedForegroundColor: context.color.primary,
            ),
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
                      text: 'Payment date',
                      style: context.text.bodyMedium?.copyWith(),
                    ),
                    TextSpan(
                      text: '*',
                      style: context.text.displaySmall?.copyWith(
                        color: context.color.primary,
                      ),
                    ),
                    TextSpan(
                      text: ': ',
                      style: context.text.bodyMedium?.copyWith(),
                    ),
                    TextSpan(
                      text: date != null
                          ? date!.dayBound == DateTime.now().dayBound
                              ? 'Today'
                              : dateFormat.format(date!)
                          : 'Not set',
                      style: context.text.bodyMedium?.copyWith(),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  await selectPaymentDate(context, setState);
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
    final grayscaleColor = context.color.inverseSurface;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isEnabled = !isEnabled;
              });
            },
            icon: Grayscale(
              grayscale: !isEnabled,
              color: grayscaleColor,
              child: Icon(
                Icons.power_settings_new_rounded,
                size: 22,
              ),
            ),
            label: FittedBox(
              child: Grayscale(
                grayscale: !isEnabled,
                color: grayscaleColor,
                child: Text(isEnabled ? 'Enabled' : 'Disabled'),
              ),
            ),
          ),
        ),
        if (targetPayment == null || (!targetPayment.isRepeat)) ...[
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isDone = !isDone;
                });
              },
              icon: Grayscale(
                grayscale: !isDone,
                color: grayscaleColor,
                child: Icon(
                  Icons.done_rounded,
                  size: 22,
                ),
              ),
              label: FittedBox(
                child: Grayscale(
                  grayscale: !isDone,
                  color: grayscaleColor,
                  child: Text(isDone ? 'Completed' : 'Not completed'),
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return OKToast(
        child: StatefulBuilder(
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
                            style: context.text.labelMedium?.copyWith(
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
                Grayscale(
                  ignore: date == null,
                  child: ElevatedButton(
                    onPressed: () {
                      final newTax = (num.tryParse(taxController.text) ?? 0.0) / 100;
                      final newMoney = num.tryParse(amountController.text) ?? 0.0;
                      final newType = type;

                      final resultPayment = targetPayment ??
                          Payment(
                            paymentId: const Uuid().v4(),
                            details: PaymentDetails(
                              name: titleController.text,
                              type: newType,
                              currency: CurrencyDataCommon.rub,
                              tax: newTax,
                            ),
                            date: date ?? DateTime(0),
                          );

                      final updated = resultPayment.copyWith(
                        isEnabled: isEnabled,
                        isDone: isDone,
                        date: date != null ? date! : DateTime(0),
                        dateStart: startDate,
                        dateEnd: endDate,
                        repeat: repeatPeriod,
                        details: resultPayment.details.copyWith(
                          name: titleController.text,
                          money: newMoney.abs(),
                          type: newType,
                          tax: newTax,
                        ),
                      );

                      final canApplyUpdate =
                          CheckPaymentCanApplyUpdate(updatedPayment: updated).run();
                      if (!canApplyUpdate.canUpdate) {
                        final canApplyUpdate = CheckPaymentCanApplyUpdate(
                          updatedPayment: resultPayment,
                        ).run();

                        final firstError = canApplyUpdate.errorKeys.firstOrNull;
                        var error = '';
                        if (firstError == MoniplanKeys.i.payments.error.requiredDate) {
                          error = 'Нужно ввести дату платежа';
                        }
                        showToast(error);
                      } else {
                        onSave(updated); // Вызываем функцию сохранения
                        Navigator.of(context).pop(); // Закрываем диалог
                      }
                    },
                    child: Text(
                      targetPayment != null ? 'Save' : 'Create',
                      style: context.text.labelLarge?.copyWith(
                        color:
                            date != null ? context.extra.moneyPositive : context.color.onSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
