import 'package:flutter/material.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monishare/_index.dart';
import 'package:moniplan_app/features/payment/repo/i_payment_planner_repo.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class MonishareDashboardScreen extends StatefulWidget {
  const MonishareDashboardScreen({super.key});

  @override
  State<MonishareDashboardScreen> createState() =>
      _MonishareDashboardScreenState();
}

class _MonishareDashboardScreenState extends State<MonishareDashboardScreen> {
  final IPlannerRepo _plannerRepo = AppDi.instance.getPlannerRepo();
  final MonishareLocalStore _localStore = AppDi.instance.get<MonishareLocalStore>();
  final MonishareService _service = AppDi.instance.get<MonishareService>();

  var _isLoading = true;
  List<Planner> _planners = const [];
  Map<String, MonishareSpaceInfo> _spaces = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _service.ensureStarted();
    final planners =
        await _plannerRepo.getPlanners(withPayments: false, withActualInfo: false);
    final spaces = <String, MonishareSpaceInfo>{};
    for (final planner in planners) {
      final info = await _localStore.loadSpace(planner.id);
      if (info != null) {
        spaces[planner.id] = info;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _planners = planners;
      _spaces = spaces;
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    await _load();
  }

  Widget _buildConnectionCard(BuildContext context) {
    final isConnected = _service.isConnected;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: isConnected ? context.color.primary : context.color.error,
                ),
                const SizedBox(width: AppSpace.s12),
                Expanded(
                  child: Text(
                    isConnected
                        ? 'Встроенный MoniShare responder активен'
                        : 'Транспорт MoniShare не запущен',
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s12),
            Text(
              'В текущей сборке сервер MoniShare работает в памяти и доступен только внутри приложения. '
              'Подключение к удаленному серверу появится позднее.',
              style: context.text.bodyMedium,
            ),
            if (!isConnected) ...[
              const SizedBox(height: AppSpace.s16),
              FilledButton.icon(
                onPressed: () async {
                  await _service.ensureStarted();
                  if (!mounted) {
                    return;
                  }
                  setState(() {});
                },
                icon: const Icon(Icons.power_settings_new),
                label: const Text('Запустить транспорт'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlannerTiles(BuildContext context) {
    if (_planners.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s16),
            child: Text('Пока нет доступных планнеров', style: context.text.bodyLarge),
          ),
        ),
      ];
    }

    return _planners.map((planner) {
      final space = _spaces[planner.id];
      final title = planner.name.isEmpty ? 'Без названия' : planner.name;
      return Card(
        child: ListTile(
          title: Text(title, style: context.text.titleMedium),
          subtitle: space != null
              ? Text('Активно пространство ${space.plannerSpaceId}',
                  style: context.text.bodyMedium)
              : Text('MoniShare ещё не настроен', style: context.text.bodyMedium),
          trailing: Icon(
            space != null ? Icons.lock_open_rounded : Icons.lock_outline,
            color: space != null ? context.color.primary : context.color.outline,
          ),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MonisharePlannerScreen(plannerId: planner.id),
              ),
            );
            if (!mounted) {
              return;
            }
            await _refresh();
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MoniShare', style: context.text.displaySmall),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(AppSpace.s16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildConnectionCard(context),
                  const SizedBox(height: AppSpace.s16),
                  Text('Планнеры', style: context.text.titleLarge),
                  const SizedBox(height: AppSpace.s8),
                  ..._buildPlannerTiles(context),
                ],
              ),
            ),
    );
  }
}
