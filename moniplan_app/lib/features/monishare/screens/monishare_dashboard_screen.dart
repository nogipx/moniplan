import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monishare/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class MonishareDashboardScreen extends StatelessWidget {
  const MonishareDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MonishareDashboardBloc(
        repository: AppDi.instance.get<MonishareRepository>(),
      )..add(const MonishareDashboardStarted()),
      child: const _MonishareDashboardView(),
    );
  }
}

class _MonishareDashboardView extends StatelessWidget {
  const _MonishareDashboardView();

  Future<void> _onRefresh(BuildContext context) async {
    final bloc = context.read<MonishareDashboardBloc>();
    bloc.add(const MonishareDashboardRefreshRequested());
    await bloc.stream.firstWhere((state) => !state.isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MonishareDashboardBloc, MonishareDashboardState>(
      listenWhen: (previous, current) =>
          previous.message != current.message ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.message != null && state.message!.isNotEmpty) {
          messenger.showSnackBar(SnackBar(content: Text(state.message!)));
        } else if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          messenger.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.message != null || state.errorMessage != null) {
          context.read<MonishareDashboardBloc>().add(const MonishareDashboardMessageCleared());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('MoniShare', style: context.text.displaySmall),
        ),
        body: BlocBuilder<MonishareDashboardBloc, MonishareDashboardState>(
          builder: (context, state) {
            if (state.isLoading && state.planners.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: ListView(
                padding: const EdgeInsets.all(AppSpace.s16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _ConnectionCard(state: state),
                  const SizedBox(height: AppSpace.s16),
                  Text('Планнеры', style: context.text.titleLarge),
                  const SizedBox(height: AppSpace.s8),
                  ..._buildPlannerTiles(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildPlannerTiles(
    BuildContext context,
    MonishareDashboardState state,
  ) {
    if (state.planners.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s16),
            child: Text('Пока нет доступных планнеров', style: context.text.bodyLarge),
          ),
        ),
      ];
    }

    return state.planners.map((planner) {
      final space = state.spaces[planner.id];
      final title = planner.name.isEmpty ? 'Без названия' : planner.name;
      return Card(
        child: ListTile(
          title: Text(title, style: context.text.titleMedium),
          subtitle: space != null
              ? Text('Активно пространство ${space.plannerSpaceId}', style: context.text.bodyMedium)
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
            if (!context.mounted) {
              return;
            }
            context.read<MonishareDashboardBloc>().add(const MonishareDashboardRefreshRequested());
          },
        ),
      );
    }).toList();
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.state});

  final MonishareDashboardState state;

  @override
  Widget build(BuildContext context) {
    final isConnected = state.isConnected;
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
                onPressed: state.isConnecting
                    ? null
                    : () {
                        context
                            .read<MonishareDashboardBloc>()
                            .add(const MonishareDashboardConnectionRequested());
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
}
