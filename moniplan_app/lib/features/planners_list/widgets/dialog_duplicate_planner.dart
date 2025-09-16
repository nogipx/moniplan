// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/utils/_index.dart';

void showDialogDuplicatePlanner(
  BuildContext context, {
  required Planner originalPlanner,
  required Function(DateTime startDate, DateTime endDate, String name) onDuplicate,
}) {
  final TextEditingController nameController =
      TextEditingController()..text = '${originalPlanner.name} (копия)';

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().monthEnd;
  bool isStartDateValid = true;

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
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
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != endDate) {
      endDate = picked;
      isStartDateValid = startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);
    }
  }

  final dateFormat = DateFormat('dd.MM.yyyy');

  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Дублировать планнер'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(labelText: 'Название нового планнера'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('Дата начала: ${dateFormat.format(startDate)}')),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        await selectStartDate(context);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('Дата окончания: ${dateFormat.format(endDate)}')),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        await selectEndDate(context);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                if (!isStartDateValid)
                  const Text(
                    'Дата начала не может быть позже даты окончания',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Будут скопированы:\n• Все настройки планнера\n• Все платежи\n• Начальный бюджет: ${originalPlanner.initialBudget.toStringAsFixed(2)} ₽',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed:
                    isStartDateValid && nameController.text.isNotEmpty
                        ? () {
                          onDuplicate(startDate, endDate, nameController.text);
                          Navigator.of(context).pop();
                        }
                        : null,
                child: const Text('Дублировать'),
              ),
            ],
          );
        },
      );
    },
  );
}
