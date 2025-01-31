// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_core/moniplan_core.dart';

void showDialogUpdatePlanner(
  BuildContext context, {
  Planner? planner,
  required Function(DateTime, DateTime, String, String) onSave,
  Function()? onDelete,
}) {
  final TextEditingController numberController = TextEditingController()
    ..text = planner?.initialBudget.toString() ?? '';
  final TextEditingController nameController = TextEditingController()
    ..text = planner?.name.toString() ?? '';
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
                  ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Enter a name',
                  ),
                ),
                const SizedBox(height: 8),
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
                        onSave(startDate, endDate, enteredNumber,
                            nameController.text); // Вызываем функцию сохранения
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
