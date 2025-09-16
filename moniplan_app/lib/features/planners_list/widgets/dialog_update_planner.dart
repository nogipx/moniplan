import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/utils/_index.dart';

void showDialogUpdatePlanner(
  BuildContext context, {
  required Function(DateTime, DateTime, String, String) onSave,
  Planner? planner,
  Function()? onDelete,
  Function()? onDuplicate,
}) {
  final numberController = TextEditingController()..text = planner?.initialBudget.toString() ?? '';
  final nameController = TextEditingController()..text = planner?.name.toString() ?? '';
  var startDate = planner?.dateStart ?? DateTime.now();
  var endDate = planner?.dateEnd ?? DateTime.now().monthEnd;
  var isStartDateValid = true;

  Future<void> selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
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
    final picked = await showDatePicker(
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
                const Spacer(),
                if (planner != null && onDuplicate != null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDuplicate();
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Дублировать'),
                  ),
                if (onDelete != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                    child: const Text('Delete'),
                  ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(labelText: 'Enter a name'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Text('Start date: ${dateFormat.format(startDate)}'),
                    if (planner == null)
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          await selectStartDate(context);
                          setState(() {});
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Text('End date: ${dateFormat.format(endDate)}'),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        await selectEndDate(context);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                if (!isStartDateValid) const Text('Start date cannot be after end date'),
                const SizedBox(height: 16),
                TextField(
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Enter a initial budget'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Закрываем диалог
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed:
                    isStartDateValid
                        ? () {
                          final enteredNumber = numberController.text;
                          onSave(
                            startDate,
                            endDate,
                            enteredNumber,
                            nameController.text,
                          ); // Вызываем функцию сохранения
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
