import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showDialogCreatePlanner(
  BuildContext context, {
  required Function(DateTime, DateTime, String) onSave,
}) {
  final TextEditingController numberController = TextEditingController();
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now().add(Duration(days: 7));
  bool isStartDateValid = true;

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      startDate = picked;
      isStartDateValid = startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate) {
      endDate = picked;
      isStartDateValid = startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Create Planner'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('Start date: ${DateFormat.yMd().format(startDate)}'),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        await selectStartDate(context);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Text('End date: ${DateFormat.yMd().format(endDate)}'),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        await selectEndDate(context);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                if (!isStartDateValid)
                  Text(
                    'Start date cannot be after end date',
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 16),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter a initial budget',
                  ),
                ),
              ],
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
              TextButton(
                onPressed: isStartDateValid
                    ? () {
                        final enteredNumber = numberController.text;
                        onSave(startDate, endDate, enteredNumber); // Вызываем функцию сохранения
                        Navigator.of(context).pop(); // Закрываем диалог
                      }
                    : null,
                child: Text('Create'),
              ),
            ],
          );
        },
      );
    },
  );
}
