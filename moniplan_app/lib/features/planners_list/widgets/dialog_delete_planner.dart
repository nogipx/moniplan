import 'package:flutter/material.dart';

void showDeletePlannerDialog(BuildContext context, VoidCallback onDelete) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Planner'),
        content: const Text(
          'Are you sure you want to delete this planner? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(); // Вызываем функцию удаления
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
