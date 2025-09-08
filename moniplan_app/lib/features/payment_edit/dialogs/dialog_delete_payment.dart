// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_app/domain/moniplan_domain.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

void showDeletePaymentDialog(BuildContext context, VoidCallback onDelete, {Payment? payment}) {
  final isRepeatParent = payment?.isRepeatParent ?? false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Удаление платежа'),
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
            child: Text('Отмена'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.color.error),
            onPressed: () {
              onDelete(); // Вызываем функцию удаления
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: Text('Удалить'),
          ),
        ],
      );
    },
  );
}
