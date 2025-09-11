part of '../monisync_screen.dart';

/// Лист с информацией о резервной копии
class BackupInfoSheet {
  /// Показывает модальное окно с информацией о файле бэкапа
  static Future<bool> show(BuildContext context, BackupInfo info) async {
    return await showModalBottomSheet<bool>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          isScrollControlled: true,
          backgroundColor: context.theme.colorScheme.surface,
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.5,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return SafeArea(
                  child: Column(
                    children: [
                      // Полоска для перетаскивания и заголовок
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 16),
                        child: Column(
                          children: [
                            Container(
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: context.theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Информация о файле',
                              style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // Основное содержимое
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          children: [
                            // Основная информация
                            _buildInfoItem(
                              context,
                              title: 'Защищено паролем',
                              subtitle: 'Для импорта потребуется ввести пароль',
                              icon: Icons.password,
                              isPrimary: true,
                            ),
                            // Основная информация
                            _buildInfoItem(
                              context,
                              title: 'Метаданные',
                              subtitle:
                                  'Создано ${info.metadata?.timestamp}\nКоличество планнеров: ${info.plannersCount}',
                              icon: Icons.info_outline,
                              isPrimary: false,
                            ),
                            const SizedBox(height: 24),

                            // Предупреждение
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.theme.colorScheme.errorContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: context.theme.colorScheme.error,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Внимание!',
                                        style: context.text.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.theme.colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Импорт бэкапа перезапишет все текущие данные в приложении. Существующие планеры и платежи будут заменены.',
                                    style: context.text.bodyMedium?.copyWith(
                                      color: context.theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Кнопки внизу
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: context.theme.colorScheme.shadow.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: context.theme.colorScheme.onSurface,
                                  side: BorderSide(color: context.theme.colorScheme.outline),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Отмена'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: context.theme.colorScheme.error,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Импортировать'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ) ??
        false;
  }

  /// Создает элемент информации с иконкой
  static Widget _buildInfoItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
  }) {
    final colorScheme = context.theme.colorScheme;
    final iconColor = isPrimary ? colorScheme.primary : colorScheme.secondary;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.text.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
