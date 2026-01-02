import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monisync/screens/monisync_screen.dart';
import 'package:moniplan_app/features/payment/repo/i_planner_actual_info_repo.dart';
import 'package:moniplan_app/features/payment/repo/i_planner_settings_repo.dart';
import 'package:moniplan_app/features/payment/repo/i_planners_repo.dart';
import 'package:moniplan_app/features/payment/repo/i_payments_repo.dart';
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
  IPlannersRepo get _plannersRepo => AppDi.instance.getPlannersRepo();
  IPaymentsRepo get _paymentsRepo => AppDi.instance.getPaymentsRepo();
  IPlannerActualInfoRepo get _actualInfoRepo =>
      AppDi.instance.getPlannerActualInfoRepo();
  IPlannerSettingsRepo get _settingsRepo =>
      AppDi.instance.getPlannerSettingsRepo();
  final _actualPlanners = ValueNotifier<List<Planner>>([]);
  final _currentPlannerId = ValueNotifier<String?>(null);
  bool _openedCurrentOnStart = false;

  @override
  void initState() {
    _updatePlannersList(openCurrentAfterLoad: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_actualPlanners, _currentPlannerId]),
      builder: (context, _) {
        return RefreshIndicator(
          onRefresh: _updatePlannersList,
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
                      await _plannersRepo.upsert(newPlanner);
                      await _updatePlannersList();
                      _openPlanner(context, newPlanner.id);
                    },
                  );
                },
              ),
            ),
            body: SafeArea(
              child: Builder(
                builder: (context) {
                  final data = _actualPlanners.value;
                  if (data.isEmpty) {
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
                    itemCount: _actualPlanners.value.length,
                    padding: const EdgeInsets.all(AppSpace.s16),
                    itemBuilder: (context, index) {
                      final planner = _actualPlanners.value[index];
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
                              await _plannersRepo.upsert(newPlanner);
                              await _updatePlannersList();
                            },
                            onDelete: () {
                              showDeletePlannerDialog(context, () async {
                                await _cascadeDeletePlanner(planner.id);
                                _updatePlannersList();
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
                                // onDuplicate: (startDate, endDate, name) async {
                                //   try {
                                //     final duplicatedPlanner = await _plannerService.duplicatePlanner(
                                //       originalPlannerId: planner.id,
                                //       newStartDate: startDate,
                                //       newEndDate: endDate,
                                //       newName: name,
                                //     );
                                //
                                //     if (duplicatedPlanner != null) {
                                //       await _updatePlannersList();
                                //       // Показываем сообщение об успехе
                                //       if (context.mounted) {
                                //         ScaffoldMessenger.of(context).showSnackBar(
                                //           SnackBar(
                                //             content: Text('Планнер "$name" успешно создан'),
                                //             action: SnackBarAction(
                                //               label: 'Открыть',
                                //               onPressed: () {
                                //                 _openPlanner(context, duplicatedPlanner.id);
                                //               },
                                //             ),
                                //           ),
                                //         );
                                //       }
                                //     }
                                //   } on Object catch (e) {
                                //     // Показываем ошибку
                                //     if (context.mounted) {
                                //       ScaffoldMessenger.of(context).showSnackBar(
                                //         SnackBar(
                                //           content: Text('Ошибка при дублировании: $e'),
                                //           backgroundColor: Theme.of(context).colorScheme.error,
                                //         ),
                                //       );
                                //     }
                                //   }
                                // },
                              );
                            },
                          );
                        },
                        child: PlannerItemWidget(
                          planner: planner,
                          isCurrent: planner.id == _currentPlannerId.value,
                          onToggleCurrent: () => _onToggleCurrent(planner),
                          onPressed: () {
                            _openPlanner(context, planner.id).then((_) {
                              _updatePlannersList();
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
    );
  }

  Future<void> _updatePlannersList({bool openCurrentAfterLoad = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final planners = await _plannersRepo.list(limit: 1000);
    final currentPlannerId =
        (await _settingsRepo.getSettings())?.currentPlannerId;
    final plannersWithActualInfo = <Planner>[];
    for (final planner in planners) {
      final actualInfo = await _actualInfoRepo.get(planner.id);
      plannersWithActualInfo.add(planner.copyWith(actualInfo: actualInfo));
    }

    if (!mounted) {
      return;
    }

    _actualPlanners.value = plannersWithActualInfo;
    _currentPlannerId.value = currentPlannerId;
    setState(() {});

    if (openCurrentAfterLoad && !_openedCurrentOnStart) {
      _openedCurrentOnStart = true;
      if (currentPlannerId != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _openPlanner(context, currentPlannerId);
          }
        });
      }
    }
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

  Future<void> _onToggleCurrent(Planner planner) async {
    try {
      if (_currentPlannerId.value == planner.id) {
        await _settingsRepo.deleteSettings();
        _currentPlannerId.value = null;
      } else {
        final settings =
            (await _settingsRepo.getSettings()) ??
            _settingsRepo.createDefaultSettings();
        await _settingsRepo.saveSettings(
          settings.copyWith(currentPlannerId: planner.id),
        );
        _currentPlannerId.value = planner.id;
      }
      setState(() {});
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось обновить текущий планнер: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _cascadeDeletePlanner(String plannerId) async {
    final payments = await _paymentsRepo.listByPlanner(plannerId);
    if (payments.isNotEmpty) {
      await _paymentsRepo.bulkDelete(
        plannerId: plannerId,
        ids: payments.map((p) => p.paymentId).toList(),
      );
    }
    await _actualInfoRepo.delete(plannerId);
    final currentPlannerId =
        (await _settingsRepo.getSettings())?.currentPlannerId;
    if (currentPlannerId == plannerId) {
      await _settingsRepo.deleteSettings();
    }
    await _plannersRepo.delete(plannerId);
  }
}
