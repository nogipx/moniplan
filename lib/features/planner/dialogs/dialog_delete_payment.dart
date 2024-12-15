import 'package:flutter/material.dart';

void showDeletePaymentDialog(BuildContext context, VoidCallback onDelete) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Payment'),
        content:
            Text('Are you sure you want to delete this payment? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(); // Вызываем функцию удаления
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}
