// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:licensify/licensify.dart';

class LicenseCard extends StatelessWidget {
  final License license;
  final bool isValid;
  final bool isExpired;
  final String? errorMessage;

  const LicenseCard({
    super.key,
    required this.license,
    required this.isValid,
    required this.isExpired,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final theme = Theme.of(context);

    Color statusColor = Colors.green;
    String statusText = 'Активна';
    IconData statusIcon = Icons.check_circle;

    if (isExpired) {
      statusColor = Colors.orange;
      statusText = 'Истек срок действия';
      statusIcon = Icons.warning_amber;
    } else if (!isValid) {
      statusColor = Colors.red;
      statusText = 'Недействительна';
      statusIcon = Icons.error;
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус лицензии
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: statusColor,
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 4),
                          Text(errorMessage!, style: TextStyle(color: statusColor)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Информация о лицензии
            Text('Информация о лицензии', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _InfoItem(title: 'ID', value: license.id),
            _InfoItem(title: 'Приложение', value: license.appId),
            _InfoItem(title: 'Тип лицензии', value: license.type.toString().split('.').last),
            _InfoItem(title: 'Дата создания', value: dateFormat.format(license.createdAt)),
            _InfoItem(
              title: 'Действительна до',
              value: dateFormat.format(license.expirationDate),
              valueColor: isExpired ? Colors.orange : null,
            ),

            // Доступные функции
            if (license.features.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Доступные функции', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              ...license.features.entries.map((entry) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check),
                  title: Text(entry.key),
                  subtitle: entry.value != null ? Text(entry.value.toString()) : null,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoItem({required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: valueColor))),
        ],
      ),
    );
  }
}
