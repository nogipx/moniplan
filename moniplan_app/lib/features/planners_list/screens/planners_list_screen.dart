import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monisync/screens/monisync_screen.dart';
import 'package:moniplan_app/features/planner/screens/planner_view_screen_sliver.dart';
import 'package:moniplan_app/features/planners_list/_index.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class PlannersListScreen extends StatefulWidget {
  const PlannersListScreen({super.key});

  @override
  State<PlannersListScreen> createState() => _PlannersListScreenState();
}

class _PlannersListScreenState extends State<PlannersListScreen> {
  bool _openedCurrentOnStart = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlannersListBloc(
        plannersRepo: AppDi.instance.getPlannersRepo(),
        paymentsRepo: AppDi.instance.getPaymentsRepo(),
        actualInfoRepo: AppDi.instance.getPlannerActualInfoRepo(),
        settingsRepo: AppDi.instance.getPlannerSettingsRepo(),
      )..add(const PlannersListLoad()),
      child: BlocConsumer<PlannersListBloc, PlannersListState>(
        listener: (context, state) {
          if (!_openedCurrentOnStart && state.currentPlannerId != null) {
            _openedCurrentOnStart = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && state.currentPlannerId != null) {
                _openPlanner(context, state.currentPlannerId!);
              }
            });
          }
        },
        builder: (context, state) {
          final planners = state.planners;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PlannersListBloc>().add(const PlannersListLoad());
            },
            child: Scaffold(
              appBar: AppBar(
                actions: [
                  const SizedBox(width: AppSpace.s20),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const SizedBox.shrink();
                          }

                          return Text(
                            'v${snap.data?.version}',
                            style: context.theme.textTheme.titleLarge,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.import_export_outlined, size: 18),
                    label: const Text('MoniSync'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const MonisyncScreen();
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: AppSpace.s20),
                ],
              ),
              floatingActionButton: GestureDetector(
                child: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    showDialogUpdatePlanner(
                      context,
                      onSave: (start, end, money, name) async {
                        final newPlanner = Planner(
                          id: const Uuid().v4(),
                          name: name,
                          dateStart: start,
                          dateEnd: end,
                          initialBudget: num.tryParse(money) ?? 0,
                          isGenerationAllowed: true,
                        );
                        context.read<PlannersListBloc>().add(
                          PlannersListAdd(newPlanner),
                        );
                        _openPlanner(context, newPlanner.id);
                      },
                    );
                  },
                ),
              ),
              body: SafeArea(
                child: Builder(
                  builder: (context) {
                    if (planners.isEmpty) {
                      return const Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 30),
                                  child: Text('No planners'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      itemCount: planners.length,
                      padding: const EdgeInsets.all(AppSpace.s16),
                      itemBuilder: (context, index) {
                        final planner = planners[index];
                        return GestureDetector(
                          onLongPress: () {
                            showDialogUpdatePlanner(
                              context,
                              planner: planner,
                              onSave: (start, end, money, name) async {
                                final newPlanner = planner.copyWith(
                                  dateStart: start,
                                  dateEnd: end,
                                  name: name,
                                  initialBudget: num.tryParse(money) ?? 0,
                                );
                                context.read<PlannersListBloc>().add(
                                  PlannersListUpdate(newPlanner),
                                );
                              },
                              onDelete: () {
                                showDeletePlannerDialog(context, () async {
                                  context.read<PlannersListBloc>().add(
                                    PlannersListDelete(planner.id),
                                  );
                                });
                              },
                              onDuplicate: () {
                                showDialogDuplicatePlanner(
                                  context,
                                  originalPlanner: planner,
                                  onDuplicate:
                                      (
                                        DateTime startDate,
                                        DateTime endDate,
                                        String name,
                                      ) {},
                                );
                              },
                            );
                          },
                          child: PlannerItemWidget(
                            planner: planner,
                            isCurrent: planner.id == state.currentPlannerId,
                            onToggleCurrent: () =>
                                context.read<PlannersListBloc>().add(
                                  PlannersListToggleCurrent(planner),
                                ),
                            onPressed: () {
                              _openPlanner(context, planner.id).then((_) {
                                context.read<PlannersListBloc>().add(
                                  const PlannersListLoad(),
                                );
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future _openPlanner(BuildContext context, String plannerId) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PlannerScreen(plannerId: plannerId);
        },
      ),
    );
  }
}
