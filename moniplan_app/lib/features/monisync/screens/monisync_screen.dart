import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monisync/bloc/monisync_bloc.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rpc_dart/logger.dart';
import 'package:share_plus/share_plus.dart';

import '../models/backup_info.dart';

part 'components/backup_action_card.dart';
part 'components/backup_info_sheet.dart';
part 'components/csv_export_dialog.dart';
part 'components/password_dialog.dart';
part 'components/protection_selector.dart';

enum _ExportFormat { dataService, sqlite }

class MonisyncScreen extends StatelessWidget {
  const MonisyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MonisyncBloc(appDi: AppDi.instance)..add(MonisyncInitEvent()),
      child: const _MonisyncScreenContent(),
    );
  }
}

class _MonisyncScreenContent extends StatefulWidget {
  const _MonisyncScreenContent();

  @override
  State<_MonisyncScreenContent> createState() => _MonisyncScreenContentState();
}

class _MonisyncScreenContentState extends State<_MonisyncScreenContent> {
  final _log = RpcLogger('MoniSync');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MonisyncBloc, MonisyncState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final isLoading = state is MonisyncLoadingState;

        return Scaffold(
          appBar: AppBar(
            title: Text('Monisync', style: context.text.displaySmall),
            centerTitle: true,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBackupSection(context),
                        const SizedBox(height: 36),
                        _buildInfoSection(context),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, MonisyncState state) {
    if (state is MonisyncErrorState) {
      showToast(state.message);
    } else if (state is MonisyncImportResultState) {
      final message = state.success
          ? (state.message ?? 'Данные успешно импортированы')
          : (state.message ?? 'Ошибка при импорте данных');
      showToast(message);
    } else if (state is MonisyncNewExportSuccessState) {
      _handleExportSuccess(context, state);
    }
  }

  Widget _buildBackupSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Резервное копирование',
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        BackupActionCard(
          title: 'Создать резервную копию',
          subtitle: 'Сохранить все ваши данные для будущего восстановления',
          icon: Icons.backup_rounded,
          iconColor: Colors.blue,
          onTap: () => _exportBackup(context),
        ),
        const SizedBox(height: 12),
        BackupActionCard(
          title: 'Восстановить из резервной копии',
          subtitle: 'Восстановить данные из ранее созданного бэкапа',
          icon: Icons.restore_rounded,
          iconColor: Colors.orange,
          onTap: () => _importBackup(context),
        ),
        if (kDebugMode) ..._buildDebugActions(context),
      ],
    );
  }

  List<Widget> _buildDebugActions(BuildContext context) {
    return [
      const SizedBox(height: 12),
      BackupActionCard(
        title: 'Скачать базу',
        subtitle: 'Экспорт базы данных (только для разработки)',
        icon: Icons.raw_on,
        iconColor: Colors.red,
        onTap: () => _downloadDb(context),
      ),
      const SizedBox(height: 12),
      BackupActionCard(
        title: 'Вставить базу',
        subtitle:
            'Импорт базы данных (.json/.ndjson/.db, только для разработки)',
        icon: Icons.add_to_home_screen,
        iconColor: Colors.red,
        onTap: () => _importDb(context),
      ),
    ];
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Информация',
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerHighest.withAlpha(
              (0.5 * 255).round(),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'О резервных копиях',
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Регулярно создавайте резервные копии ваших данных, чтобы избежать их потери. '
                'Все резервные копии защищены паролем для обеспечения безопасности.',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Поддерживается импорт старых резервных копий, созданных с пользовательским паролем.',
                style: context.text.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final bloc = context.read<MonisyncBloc>();
    final password = await PasswordDialog.show(context);
    if (password == null || password.isEmpty) {
      showToast('Пароль обязателен для создания резервной копии');
      return;
    }

    if (!mounted) {
      return;
    }
    bloc.add(MonisyncExportNewEvent(password: password));
  }

  Future<void> _handleExportSuccess(
    BuildContext context,
    MonisyncNewExportSuccessState state,
  ) async {
    if (!context.mounted) {
      return;
    }

    final shareOption = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          _buildExportOptionsSheet(context, title: 'Резервная копия'),
    );

    if (shareOption == null || !context.mounted) {
      return;
    }

    try {
      if (shareOption) {
        await _shareFile(state.bytes, state.fileName);
      } else {
        await _saveFile(state.bytes, state.fileName);
      }
    } on Object catch (error) {
      _log.error('Ошибка при сохранении/отправке файла', error: error);
      showToast('Ошибка при сохранении файла');
    }
  }

  Future<void> _shareFile(List<int> bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);

    final xFile = XFile(tempFile.path, mimeType: 'application/octet-stream');
    await Share.shareXFiles(
      [xFile],
      subject: 'Резервная копия Moniplan',
      text:
          'Резервная копия Moniplan от ${DateFormat('dd.MM.yyyy').format(DateTime.now())}',
    );

    showToast('Резервная копия отправлена');
  }

  Future<void> _saveFile(List<int> bytes, String fileName) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Сохранение резервной копии',
      fileName: fileName,
      bytes: Uint8List.fromList(bytes),
    );

    if (result != null) {
      await File(result).writeAsBytes(bytes);
      showToast('Резервная копия сохранена');
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result == null) {
      return;
    }
    if (result.files.isEmpty) {
      return;
    }

    final picked = result.files.first;
    final bytes = picked.bytes;
    final filePath = picked.path;

    if (bytes != null) {
      // На вебе читаем первые байты из bytes
      final isNew = _isNewFormatFromBytes(bytes);
      if (isNew) {
        final token = utf8.decode(bytes);
        await _importNewFormatBackupFromToken(context, token);
        return;
      }
      showToast('Неподдерживаемый формат резервной копии');
      return;
    }

    if (filePath == null) {
      showToast('Ошибка при выборе файла');
      return;
    }

    // На нативных платформах можно читать первые байты файла
    try {
      final isNew =
          filePath.endsWith('.moniplan') || await _isNewFormatFile(filePath);
      if (isNew) {
        await _importNewFormatBackup(context, filePath);
      } else {
        showToast('Неподдерживаемый формат резервной копии');
      }
    } on Object catch (error) {
      _log.error('Ошибка определения формата файла', error: error);
      showToast('Не удалось определить формат файла');
    }
  }

  /// Проверяет, является ли файл новым форматом (начинается с "v4.local")
  Future<bool> _isNewFormatFile(String filePath) async {
    try {
      final file = File(filePath);
      final raf = await file.open();
      const int checkLen = 8; // длина префикса 'v4.local'
      final bytes = await raf.read(checkLen);
      await raf.close();
      return _isNewFormatFromBytes(bytes);
    } on Object catch (error) {
      // Если не удалось прочитать — считаем, что не новый формат
      _log.error('Ошибка при проверке первых байтов файла', error: error);
      return false;
    }
  }

  /// Проверяет первые байты на сигнатуру нового формата
  bool _isNewFormatFromBytes(Uint8List bytes) {
    try {
      if (bytes.isEmpty) {
        return false;
      }
      final int sampleLength = bytes.length < 8 ? bytes.length : 8;
      final String sample = utf8.decode(
        bytes.sublist(0, sampleLength),
        allowMalformed: true,
      );
      return sample.startsWith('v4.local');
    } on Object catch (_) {
      return false;
    }
  }

  /// Обработка нового формата когда token уже есть в памяти
  Future<void> _importNewFormatBackupFromToken(
    BuildContext context,
    String token,
  ) async {
    final bloc = context.read<MonisyncBloc>();
    bloc.add(MonisyncReadNewBackupInfoEvent(token: token));

    await _listenForBackupInfo(context, (state) async {
      if (state is MonisyncNewBackupInfoState) {
        await _showBackupInfoAndImport(context, state.backupInfo, token);
      } else if (state is MonisyncErrorState) {
        await _requestPasswordAndImportNew(context, token);
      }
    });
  }

  Future<void> _importNewFormatBackup(
    BuildContext context,
    String filePath,
  ) async {
    try {
      final bloc = context.read<MonisyncBloc>();
      final file = File(filePath);
      final token = await file.readAsString();

      // Сначала попробуем прочитать информацию о бэкапе без пароля
      if (!mounted) {
        return;
      }
      bloc.add(MonisyncReadNewBackupInfoEvent(token: token));

      // Слушаем один раз для получения информации о бэкапе
      await _listenForBackupInfo(context, (state) async {
        if (state is MonisyncNewBackupInfoState) {
          await _showBackupInfoAndImport(context, state.backupInfo, token);
        } else if (state is MonisyncErrorState) {
          await _requestPasswordAndImportNew(context, token);
        }
      });
    } on Object catch (error) {
      _log.error('Ошибка при чтении файла', error: error);
      showToast('Ошибка при чтении файла резервной копии');
    }
  }

  Future<void> _requestPasswordAndImportNew(
    BuildContext context,
    String token,
  ) async {
    final bloc = context.read<MonisyncBloc>();
    final password = await PasswordDialog.show(context);
    if (password == null || password.isEmpty) {
      showToast('Пароль обязателен для импорта резервной копии');
      return;
    }

    if (!mounted) {
      return;
    }
    bloc.add(MonisyncReadNewBackupInfoEvent(token: token, password: password));

    await _listenForBackupInfo(context, (state) async {
      if (state is MonisyncNewBackupInfoState) {
        await _importWithToken(context, token, password);
      }
    });
  }

  Future<void> _listenForBackupInfo(
    BuildContext context,
    Function(MonisyncState) onState,
  ) async {
    final bloc = context.read<MonisyncBloc>();
    await for (final state in bloc.stream) {
      await onState(state);
      if (state is MonisyncNewBackupInfoState || state is MonisyncErrorState) {
        break;
      }
    }
  }

  Future<void> _showBackupInfoAndImport(
    BuildContext context,
    BackupInfo backupInfo,
    String token,
  ) async {
    if (!context.mounted) {
      return;
    }

    final shouldImport = await BackupInfoSheet.show(context, backupInfo);
    if (shouldImport != true || !context.mounted) {
      return;
    }

    final password = await PasswordDialog.show(context);
    if (password == null || password.isEmpty) {
      showToast('Пароль обязателен для импорта');
      return;
    }

    await _importWithToken(context, token, password);
  }

  Future<void> _importWithToken(
    BuildContext context,
    String token,
    String password,
  ) async {
    if (context.mounted) {
      context.read<MonisyncBloc>().add(
        MonisyncImportNewEvent(token: token, password: password),
      );
    }
  }

  Widget _buildExportOptionsSheet(
    BuildContext context, {
    String title = 'Выберите действие',
    String saveText = 'Файл будет сохранен в выбранном месте',
    String shareText = 'Отправить через мессенджер или почту',
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title,
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildOptionCard(
              context,
              icon: Icons.save_alt_rounded,
              title: 'Сохранить на устройстве',
              subtitle: saveText,
              onTap: () => Navigator.of(context).pop(false),
              color: context.theme.colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context,
              icon: Icons.share_rounded,
              title: 'Поделиться',
              subtitle: shareText,
              onTap: () => Navigator.of(context).pop(true),
              color: context.theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerHighest.withAlpha(
        (0.3 * 255).round(),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha((0.12 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Debug функции
  Future<void> _downloadDb(BuildContext context) async {
    try {
      final format = await _pickExportFormat(context);
      if (format == null) {
        return;
      }

      final now = DateTime.now();
      late final List<int> bytes;
      late final String fileName;

      if (format == _ExportFormat.dataService) {
        bytes = await _exportDataServiceDump();
        fileName =
            'moniplan_db_${DateFormat('yyyyMMdd_HHmmss').format(now)}.ndjson';
      } else {
        final db = AppDi.instance.getDb();
        bytes = await db.exportSqlite();
        fileName =
            'moniplan_db_${DateFormat('yyyyMMdd_HHmmss').format(now)}.db';
      }

      if (!context.mounted) {
        return;
      }

      final shareOption = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: context.theme.colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) =>
            _buildExportOptionsSheet(context, title: 'База данных'),
      );

      if (shareOption == null) {
        return;
      }

      if (shareOption) {
        await _shareFile(bytes, fileName);
      } else {
        await _saveFile(bytes, fileName);
      }
    } on Object catch (error) {
      _log.error('Ошибка экспорта базы данных', error: error);
      showToast('Ошибка при экспорте базы данных');
    }
  }

  Future<void> _importDb(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'ndjson', 'db'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final pickedFile = result.files.first;
    final extension = (pickedFile.extension ?? '').toLowerCase();

    try {
      if (extension == 'json' || extension == 'ndjson') {
        final payload = await _readPickedFileAsString(pickedFile);
        if (payload == null) {
          showToast('Не удалось прочитать файл');
          return;
        }
        final dataService = AppDi.instance.getDataService();
        await dataService.importDatabase(
          payload: payload,
          replaceExisting: true,
        );
        showToast('База данных импортирована через IDataService');
      } else {
        final bytes = await _readPickedFileAsBytes(pickedFile);
        if (bytes == null) {
          showToast('Не удалось прочитать файл');
          return;
        }
        final db = AppDi.instance.getDb();
        await db.importSqlite(bytes: bytes);
        showToast('База данных импортирована из файла SQLite');
      }
    } on Object catch (error) {
      _log.error('Ошибка импорта базы данных', error: error);
      showToast('Ошибка при импорте базы данных');
    }
  }

  Future<String?> _readPickedFileAsString(PlatformFile file) async {
    if (file.bytes != null) {
      return utf8.decode(file.bytes!);
    }

    final path = file.path;
    if (path == null) {
      return null;
    }

    final ioFile = File(path);
    if (!ioFile.existsSync()) {
      return null;
    }

    return ioFile.readAsString();
  }

  Future<Uint8List?> _readPickedFileAsBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes;
    }

    final path = file.path;
    if (path == null) {
      return null;
    }

    final ioFile = File(path);
    if (!ioFile.existsSync()) {
      return null;
    }

    return ioFile.readAsBytes();
  }

  Future<_ExportFormat?> _pickExportFormat(BuildContext context) {
    return showModalBottomSheet<_ExportFormat>(
      context: context,
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Экспорт через IDataService (NDJSON)'),
              subtitle: const Text('Использует exportDatabase/importDatabase'),
              onTap: () => Navigator.of(context).pop(_ExportFormat.dataService),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Экспорт SQLite файла (.db)'),
              subtitle: const Text('Файл базы данных напрямую'),
              onTap: () => Navigator.of(context).pop(_ExportFormat.sqlite),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<List<int>> _exportDataServiceDump() async {
    final dataService = AppDi.instance.getDataService();
    final export = await dataService.exportDatabase(
      includePayloadString: false,
    );
    final stream = export.payloadStream;
    if (stream != null) {
      final chunks = <int>[];
      await for (final chunk in stream) {
        chunks.addAll(chunk);
      }
      return chunks;
    }
    return utf8.encode(export.payload);
  }
}
