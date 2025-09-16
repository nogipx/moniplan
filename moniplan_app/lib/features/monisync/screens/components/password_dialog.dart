part of '../monisync_screen.dart';

/// Диалог для ввода пароля
class PasswordDialog {
  /// Показывает диалог для ввода пароля
  static Future<String?> show(BuildContext context, {bool isExport = true}) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var showPassword = false;

    return showDialog<String>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 16),
                  contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  title: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(isExport ? Icons.lock_outline : Icons.key, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isExport ? 'Защита экспорта' : 'Ввод пароля',
                        style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isExport
                              ? 'Создайте пароль для защиты ваших данных'
                              : 'Введите пароль для расшифровки файла',
                          style: context.text.bodyMedium?.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: controller,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            hintText: isExport ? 'Минимум 6 символов' : 'Введите пароль',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: context.theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => showPassword = !showPassword),
                              tooltip: showPassword ? 'Скрыть пароль' : 'Показать пароль',
                            ),
                            filled: true,
                            fillColor: context.theme.colorScheme.surfaceContainerHighest.withAlpha(
                              (0.3 * 255).round(),
                            ),
                          ),
                          validator: (value) {
                            if (isExport && (value == null || value.length < 6)) {
                              return 'Пароль должен содержать минимум 6 символов';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if (!isExport || formKey.currentState!.validate()) {
                              Navigator.of(context).pop(controller.text);
                            }
                          },
                        ),
                        if (isExport) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Запомните этот пароль! Без него вы не сможете восстановить данные.',
                                    style: context.text.bodySmall?.copyWith(
                                      color: Colors.red.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Отмена',
                        style: context.text.labelLarge?.copyWith(
                          color: context.theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (!isExport || formKey.currentState!.validate()) {
                          Navigator.of(context).pop(controller.text);
                        }
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Подтвердить'),
                    ),
                  ],
                  actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                ),
          ),
    );
  }
}
