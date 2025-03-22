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
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365));
  String? _generatedLicensePath;
  bool _isLoading = false;

  // Инициализируем сервис генерации лицензий
  final _licenseGeneratorService = LicenseGeneratorService();

  @override
  void initState() {
    super.initState();
    _updateExpirationDateField();
  }

  void _updateExpirationDateField() {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    _expirationDateController.text = formatter.format(_expirationDate);
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

  Future<void> _generateLicense() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Генерируем лицензию с помощью сервиса
      final license = _licenseGeneratorService.generateLicense(
        appId: 'moniplan.nogipx.dev',
        expirationDate: _expirationDate,
        type: LicenseType.pro,
        metadata: {'generatedAt': DateTime.now().toIso8601String()},
      );

      // Сохраняем лицензию в файл
      final tempDir = await getTemporaryDirectory();
      final licenseFileName =
          'moniplan_license_${DateFormat('yyyyMMdd').format(DateTime.now())}.licensify';
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

    try {
      await Share.shareXFiles([XFile(_generatedLicensePath!)], text: 'Лицензия Moniplan');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при отправке файла: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _applyLicense() async {
    if (_generatedLicensePath == null) return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при применении лицензии: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _expirationDateController.dispose();
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

            // Поле для выбора даты окончания лицензии
            TextField(
              controller: _expirationDateController,
              decoration: const InputDecoration(
                labelText: 'Дата окончания',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectExpirationDate,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Путь к файлу: $_generatedLicensePath'),
                      const SizedBox(height: 8),
                      Text('Дата окончания: ${DateFormat('dd.MM.yyyy').format(_expirationDate)}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareLicense,
                      icon: const Icon(Icons.share),
                      label: const Text('Поделиться'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _applyLicense,
                      icon: const Icon(Icons.check_circle),
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
