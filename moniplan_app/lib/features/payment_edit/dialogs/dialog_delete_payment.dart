import 'package:flutter/material.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

void showDeletePaymentDialog(BuildContext context, VoidCallback onDelete, {Payment? payment}) {
  final isRepeatParent = payment?.isRepeatParent ?? false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Удаление платежа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRepeatParent
                  ? 'Вы уверены, что хотите удалить этот повторяющийся платеж?'
                  : 'Вы уверены, что хотите удалить этот платеж?',
              style: context.text.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: context.color.error, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Это действие нельзя будет отменить.',
                    style: context.text.bodyMedium?.copyWith(color: context.color.error),
                  ),
                ),
              ],
            ),
            if (isRepeatParent) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.delete_sweep, color: context.color.tertiary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Будут удалены все будущие повторения этого платежа.',
                      style: context.text.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.color.error),
            onPressed: () {
              onDelete(); // Вызываем функцию удаления
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: const Text('Удалить'),
          ),
        ],
      );
    },
  );
}
