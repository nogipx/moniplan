part of '../monisync_screen.dart';

/// Диалог выбора планера для экспорта в CSV
class CsvExportDialog extends StatelessWidget {
  final List<Planner> planners;
  final void Function(String plannerId) onSelect;

  const CsvExportDialog({Key? key, required this.planners, required this.onSelect})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите планер для экспорта'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: planners.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final planner = planners[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.table_chart, color: Colors.green.shade700),
              ),
              title: Text(
                planner.name,
                style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${planner.payments.length} платежей', style: context.text.bodyMedium),
              onTap: () {
                Navigator.of(context).pop();
                onSelect(planner.id);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
      ],
    );
  }
}
