part of '../monisync_screen.dart';

/// Селектор типа защиты резервной копии
class ProtectionSelector {
  /// Показывает модальное окно выбора защиты бэкапа
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Экспорт данных',
                  style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Выберите тип шифрования для резервной копии:',
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield, color: Colors.blue),
                  ),
                  title: const Text('Стандартное шифрование'),
                  subtitle: const Text('Данные будут зашифрованы ключом приложения'),
                  onTap: () => Navigator.of(context).pop(false),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.enhanced_encryption, color: Colors.green),
                  ),
                  title: const Text('Защита паролем'),
                  subtitle: const Text(
                    'Данные будут зашифрованы вашим паролем для дополнительной безопасности',
                  ),
                  onTap: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }
}
