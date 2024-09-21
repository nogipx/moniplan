import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';

void showDialogUpdatePlanner(
  BuildContext context, {
  Planner? planner,
  required Function(DateTime, DateTime, String) onSave,
  Function()? onDelete,
}) {
  final TextEditingController numberController = TextEditingController()
    ..text = planner?.initialBudget.toString() ?? '';
  DateTime startDate = planner?.dateStart ?? DateTime.now();
  DateTime endDate = planner?.dateEnd ?? DateTime.now().monthEnd;
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

  final dateFormat = DateFormat(plannerBoundDateFormat);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Row(
              children: [
                Text(planner != null ? 'Edit Planner' : 'Create Planner'),
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('Start date: ${dateFormat.format(startDate)}'),
                    if (planner == null)
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
                    Text('End date: ${dateFormat.format(endDate)}'),
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
              ),
              TextButton(
                onPressed: isStartDateValid
                    ? () {
                        final enteredNumber = numberController.text;
                        onSave(startDate, endDate, enteredNumber); // Вызываем функцию сохранения
                        Navigator.of(context).pop(); // Закрываем диалог
                      }
                    : null,
                child: Text(planner != null ? 'Save' : 'Create'),
              ),
            ],
          );
        },
      );
    },
  );
}
