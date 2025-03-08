// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:moniplan_domain/moniplan_domain.dart';
import 'package:provider/provider.dart';

import '../providers/analyzer_settings_provider.dart';

/// Экран настроек анализаторов
class AnalyzerSettingsScreen extends StatelessWidget {
  /// Конструктор
  const AnalyzerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyzerSettingsProvider(),
      child: const _AnalyzerSettingsView(),
    );
  }
}

class _AnalyzerSettingsView extends StatelessWidget {
  const _AnalyzerSettingsView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalyzerSettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки анализаторов')),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Выберите анализаторы, которые будут использоваться для генерации инсайтов',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const Divider(),
                  ...provider.analyzers.map(
                    (analyzer) => _buildAnalyzerItem(context, analyzer, provider),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () => provider.saveSettings(),
                      child: const Text('Сохранить настройки'),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildAnalyzerItem(
    BuildContext context,
    AnalyzerDescriptor analyzer,
    AnalyzerSettingsProvider provider,
  ) {
    final theme = Theme.of(context);
    final isEnabled = provider.isAnalyzerEnabled(analyzer.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(analyzer.name, style: theme.textTheme.titleMedium)),
                Switch(
                  value: isEnabled,
                  onChanged: (value) => provider.toggleAnalyzer(analyzer.id, value),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(analyzer.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            _buildAnalyzerTypeBadge(context, analyzer.type),
            if (analyzer.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: analyzer.tags.map((tag) => _buildTagChip(context, tag)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzerTypeBadge(BuildContext context, AnalyzerType type) {
    final theme = Theme.of(context);

    Color backgroundColor;
    String label;

    switch (type) {
      case AnalyzerType.retrospective:
        backgroundColor = Colors.blue.shade100;
        label = 'Ретроспективный';
        break;
      case AnalyzerType.predictive:
        backgroundColor = Colors.green.shade100;
        label = 'Прогностический';
        break;
      case AnalyzerType.combined:
        backgroundColor = Colors.purple.shade100;
        label = 'Комбинированный';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(tag, style: theme.textTheme.bodySmall),
    );
  }
}
