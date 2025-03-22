// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:licensify/licensify.dart';
import 'package:moniplan_app/features/license/bloc/_index.dart';
import 'package:moniplan_app/features/license/repository/license_generator_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LicenseGeneratorPage extends StatefulWidget {
  const LicenseGeneratorPage({super.key});

  @override
  State<LicenseGeneratorPage> createState() => _LicenseGeneratorPageState();
}

class _LicenseGeneratorPageState extends State<LicenseGeneratorPage> {
  final _expirationDateController = TextEditingController();
  final _metadataController = TextEditingController();
  final _appIdController = TextEditingController(text: 'moniplan.nogipx.dev');

  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));
  TimeOfDay _expirationTime = TimeOfDay.now();
  String? _generatedLicensePath;
  LicenseType _selectedType = LicenseType.pro;
  bool _isLoading = false;
  bool _isSharingLoading = false;
  bool _isApplyingLoading = false;

  // Инициализируем сервис генерации лицензий
  final _licenseGeneratorService = LicenseGeneratorService();

  @override
  void initState() {
    super.initState();
    _updateExpirationDateField();
  }

  void _updateExpirationDateField() {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    final combined = DateTime(
      _expirationDate.year,
      _expirationDate.month,
      _expirationDate.day,
      _expirationTime.hour,
      _expirationTime.minute,
    );
    _expirationDateController.text = formatter.format(combined);
  }

  DateTime _getCombinedDateTime() {
    return DateTime(
      _expirationDate.year,
      _expirationDate.month,
      _expirationDate.day,
      _expirationTime.hour,
      _expirationTime.minute,
    );
  }

  Future<void> _selectExpirationDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate != null && pickedDate != _expirationDate) {
      setState(() {
        _expirationDate = pickedDate;
        _updateExpirationDateField();
      });
    }
  }

  Future<void> _selectExpirationTime() async {
    final pickedTime = await showTimePicker(context: context, initialTime: _expirationTime);

    if (pickedTime != null && pickedTime != _expirationTime) {
      setState(() {
        _expirationTime = pickedTime;
        _updateExpirationDateField();
      });
    }
  }

  Map<String, dynamic>? _parseMetadata() {
    if (_metadataController.text.isEmpty) return null;

    try {
      // Пробуем распарсить JSON
      final metadataMap = jsonDecode(_metadataController.text);
      if (metadataMap is Map<String, dynamic>) {
        return metadataMap;
      }
      return null;
    } catch (_) {
      // Если не JSON, то создаем простую запись с описанием
      return {'description': _metadataController.text};
    }
  }

  Future<void> _generateLicense() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Получаем комбинированную дату и время
      final expirationDateTime = _getCombinedDateTime();

      // Получаем метаданные
      final metadata = _parseMetadata() ?? {};
      metadata['generatedAt'] = DateTime.now().toIso8601String();

      // Генерируем лицензию с помощью сервиса
      final license = _licenseGeneratorService.generateLicense(
        appId: _appIdController.text,
        expirationDate: expirationDateTime,
        type: _selectedType,
        metadata: metadata,
      );

      // Сохраняем лицензию в файл
      final tempDir = await getTemporaryDirectory();
      final licenseFileName =
          'moniplan_license_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.licensify';
      final licenseFile = File('${tempDir.path}/$licenseFileName');
      await licenseFile.writeAsBytes(license.bytes);

      setState(() {
        _generatedLicensePath = licenseFile.path;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Лицензия успешно сгенерирована'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _shareLicense() async {
    if (_generatedLicensePath == null) return;

    setState(() {
      _isSharingLoading = true;
    });

    try {
      await Share.shareXFiles([XFile(_generatedLicensePath!)], text: 'Лицензия Moniplan');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при отправке файла: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSharingLoading = false;
      });
    }
  }

  Future<void> _applyLicense() async {
    if (_generatedLicensePath == null) return;

    setState(() {
      _isApplyingLoading = true;
    });

    try {
      final licenseFile = File(_generatedLicensePath!);
      final licenseBytes = await licenseFile.readAsBytes();

      // Добавляем лицензию через блок
      context.read<LicenseBloc>().add(LicenseAddedEvent(licenseBytes: licenseBytes));

      // Показываем сообщение об успешном применении
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Лицензия успешно применена'), backgroundColor: Colors.green),
      );

      // Возвращаемся на предыдущий экран
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при применении лицензии: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isApplyingLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _expirationDateController.dispose();
    _metadataController.dispose();
    _appIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Генератор лицензий')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Создание лицензии Moniplan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Поле для выбора AppID
            TextField(
              controller: _appIdController,
              decoration: const InputDecoration(
                labelText: 'ID приложения',
                border: OutlineInputBorder(),
                helperText: 'Уникальный идентификатор приложения',
              ),
            ),

            const SizedBox(height: 16),

            // Поле для выбора даты окончания лицензии
            TextField(
              controller: _expirationDateController,
              decoration: const InputDecoration(
                labelText: 'Дата и время окончания',
                border: OutlineInputBorder(),
                helperText: 'Нажмите для выбора даты и времени',
              ),
              readOnly: true,
              onTap: () async {
                await _selectExpirationDate();
                if (mounted) {
                  await _selectExpirationTime();
                }
              },
            ),

            const SizedBox(height: 16),

            // Выбор типа лицензии
            DropdownButtonFormField<LicenseType>(
              decoration: const InputDecoration(
                labelText: 'Тип лицензии',
                border: OutlineInputBorder(),
                helperText: 'Выберите уровень доступа',
              ),
              value: _selectedType,
              items: [
                DropdownMenuItem(
                  value: LicenseType.trial,
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: Colors.orange.shade300, size: 18),
                      const SizedBox(width: 8),
                      const Text('Пробная (Trial)'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: LicenseType.standard,
                  child: Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.blue.shade300, size: 18),
                      const SizedBox(width: 8),
                      const Text('Стандартная (Standard)'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: LicenseType.pro,
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.green.shade300, size: 18),
                      const SizedBox(width: 8),
                      const Text('Профессиональная (Pro)'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Поле для метаданных
            TextField(
              controller: _metadataController,
              decoration: const InputDecoration(
                labelText: 'Метаданные лицензии',
                border: OutlineInputBorder(),
                helperText: 'Описание, информация о владельце, JSON и т.д.',
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Кнопка для генерации лицензии
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateLicense,
              icon:
                  _isLoading
                      ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(strokeWidth: 3),
                      )
                      : const Icon(Icons.vpn_key),
              label: const Text('Сгенерировать лицензию'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),

            const SizedBox(height: 16),

            if (_generatedLicensePath != null) ...[
              const Divider(height: 48),

              const Text(
                'Лицензия успешно сгенерирована!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Приложение: ${_appIdController.text}'),
                      const SizedBox(height: 8),
                      Text('Тип лицензии: ${_selectedType.name}'),
                      const SizedBox(height: 8),
                      Text(
                        'Дата окончания: ${DateFormat('dd.MM.yyyy HH:mm').format(_getCombinedDateTime())}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSharingLoading ? null : _shareLicense,
                      icon:
                          _isSharingLoading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                              : const Icon(Icons.share),
                      label: const Text('Поделиться'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isApplyingLoading ? null : _applyLicense,
                      icon:
                          _isApplyingLoading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.check_circle),
                      label: const Text('Применить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
