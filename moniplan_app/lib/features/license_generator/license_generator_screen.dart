// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:licensify/licensify.dart';
import 'package:moniplan_app/features/license_generator/license_generator_service.dart';
import 'package:oktoast/oktoast.dart';

/// Экран для генерации лицензий
class LicenseGeneratorScreen extends StatefulWidget {
  const LicenseGeneratorScreen({super.key});

  @override
  State<LicenseGeneratorScreen> createState() => _LicenseGeneratorScreenState();
}

class _LicenseGeneratorScreenState extends State<LicenseGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseService = LicenseGeneratorService();

  // Значения полей формы
  String _appId = 'com.example.app';
  LicenseType _licenseType = LicenseType.pro;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));
  final Map<String, dynamic> _features = {};
  final Map<String, dynamic> _metadata = {};

  // Поле для добавления новой фичи или метаданных
  final _featureKeyController = TextEditingController();
  final _featureValueController = TextEditingController();
  final _metadataKeyController = TextEditingController();
  final _metadataValueController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _featureKeyController.dispose();
    _featureValueController.dispose();
    _metadataKeyController.dispose();
    _metadataValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Генерация лицензии')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App ID
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ID приложения',
                  hintText: 'com.example.app',
                ),
                initialValue: _appId,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ID приложения';
                  }
                  return null;
                },
                onChanged: (value) => _appId = value,
              ),
              const SizedBox(height: 16),

              // Тип лицензии
              DropdownButtonFormField<LicenseType>(
                decoration: const InputDecoration(labelText: 'Тип лицензии'),
                value: _licenseType,
                items: [
                  DropdownMenuItem(value: LicenseType.trial, child: const Text('Trial')),
                  DropdownMenuItem(value: LicenseType.standard, child: const Text('Standard')),
                  DropdownMenuItem(value: LicenseType.pro, child: const Text('Pro')),
                  DropdownMenuItem(
                    value: LicenseType('enterprise'),
                    child: const Text('Enterprise'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _licenseType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Дата окончания
              ListTile(
                title: const Text('Дата окончания'),
                subtitle: Text(_formatDate(_expirationDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectExpirationDate,
              ),
              const Divider(),

              // Фичи
              _buildSectionHeader('Функции'),
              ..._buildFeaturesList(),
              _buildAddItemForm(
                keyController: _featureKeyController,
                valueController: _featureValueController,
                onAdd: _addFeature,
                keyLabel: 'Ключ функции',
                valueLabel: 'Значение',
              ),
              const Divider(),

              // Метаданные
              _buildSectionHeader('Метаданные'),
              ..._buildMetadataList(),
              _buildAddItemForm(
                keyController: _metadataKeyController,
                valueController: _metadataValueController,
                onAdd: _addMetadata,
                keyLabel: 'Ключ метаданных',
                valueLabel: 'Значение',
              ),

              const SizedBox(height: 32),

              // Кнопка генерации
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateLicense,
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Сгенерировать и поделиться'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  List<Widget> _buildFeaturesList() {
    if (_features.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Нет добавленных функций'),
        ),
      ];
    }

    return _features.entries.map((entry) {
      return ListTile(
        title: Text(entry.key),
        subtitle: Text(entry.value.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _features.remove(entry.key);
            });
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildMetadataList() {
    if (_metadata.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Нет добавленных метаданных'),
        ),
      ];
    }

    return _metadata.entries.map((entry) {
      return ListTile(
        title: Text(entry.key),
        subtitle: Text(entry.value.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _metadata.remove(entry.key);
            });
          },
        ),
      );
    }).toList();
  }

  Widget _buildAddItemForm({
    required TextEditingController keyController,
    required TextEditingController valueController,
    required Function() onAdd,
    required String keyLabel,
    required String valueLabel,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: keyController,
            decoration: InputDecoration(labelText: keyLabel, hintText: 'key'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: valueController,
            decoration: InputDecoration(labelText: valueLabel, hintText: 'value'),
          ),
        ),
        IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
      ],
    );
  }

  void _addFeature() {
    final key = _featureKeyController.text.trim();
    final value = _featureValueController.text.trim();

    if (key.isNotEmpty) {
      setState(() {
        // Пытаемся преобразовать значение в число, если возможно
        if (value.isEmpty) {
          _features[key] = true;
        } else {
          final numValue = num.tryParse(value);
          _features[key] = numValue ?? value;
        }
      });
      _featureKeyController.clear();
      _featureValueController.clear();
    }
  }

  void _addMetadata() {
    final key = _metadataKeyController.text.trim();
    final value = _metadataValueController.text.trim();

    if (key.isNotEmpty) {
      setState(() {
        _metadata[key] = value.isEmpty ? '' : value;
      });
      _metadataKeyController.clear();
      _metadataValueController.clear();
    }
  }

  Future<void> _selectExpirationDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (pickedDate != null && pickedDate != _expirationDate) {
      setState(() {
        _expirationDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 23, 59, 59);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _generateLicense() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _licenseService.generateAndShareLicense(
          appId: _appId,
          expirationDate: _expirationDate,
          type: _licenseType,
          features: _features,
          metadata: _metadata,
        );
        showToast('Лицензия успешно сгенерирована');
      } catch (e) {
        showToast('Ошибка при генерации лицензии: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
