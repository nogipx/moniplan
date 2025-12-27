import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moniplan_app/_run/app_di_impl.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monisync/screens/monisync_screen.dart';
import 'package:moniplan_app/features/payment/repo/i_payment_planner_repo.dart';
import 'package:moniplan_app/features/planner/_index.dart';
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
  IPlannerRepo get _plannerRepo => AppDi.instance.getPlannerRepo();
  final _actualPlanners = ValueNotifier<List<Planner>>([]);

  @override
  void initState() {
    _updatePlannersList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_actualPlanners]),
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
              onLongPress: null,
              onDoubleTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => AppColorsDisplayScreen()));
              },
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
                      await _plannerRepo.savePlanner(newPlanner).then((planner) async {
                        await _updatePlannersList();
                        if (planner != null) {
                          _openPlanner(context, planner.id);
                        }
                      });
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
                              await _plannerRepo.savePlanner(newPlanner).then((planner) async {
                                await _updatePlannersList();
                              });
                            },
                            onDelete: () {
                              showDeletePlannerDialog(context, () async {
                                await _plannerRepo.deletePlanner(planner.id);
                                _updatePlannersList();
                              });
                            },
                            onDuplicate: () {
                              showDialogDuplicatePlanner(
                                context,
                                originalPlanner: planner,
                                onDuplicate: (DateTime startDate, DateTime endDate, String name) {},
                                // onDuplicate: (startDate, endDate, name) async {
                                //   try {
                                //     final duplicatedPlanner = await _plannerRepo.duplicatePlanner(
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

  Future<void> _updatePlannersList() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final planners = await _plannerRepo.getPlanners();
    _actualPlanners.value = planners;
    setState(() {});
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
