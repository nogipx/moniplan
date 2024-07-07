import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/features/payment_planner/_index.dart';
import 'package:moniplan/features/planners_list/_index.dart';
import 'package:moniplan/features/planners_list/widgets/dialog_update_planner.dart';
import 'package:moniplan/features/planners_list/widgets/dialog_delete_planner.dart';
import 'package:moniplan/main.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PlannersListScreen extends StatefulWidget {
  const PlannersListScreen({super.key});

  @override
  State<PlannersListScreen> createState() => _PlannersListScreenState();
}

class _PlannersListScreenState extends State<PlannersListScreen> {
  late IPlannerRepo _plannerRepo;
  final _planners = ValueNotifier<List<PaymentPlanner>>([]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePlannersList();
  }

  @override
  void initState() {
    super.initState();
    _plannerRepo = PlannerRepoDrift(db: db);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: GestureDetector(
        onLongPress: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DriftDbViewer(db),
            ),
          );
        },
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showDialogUpdatePlanner(
              context,
              onSave: (start, end, money) async {
                final newPlanner = PaymentPlanner(
                  id: const Uuid().v4(),
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
        child: ValueListenableBuilder(
          valueListenable: _planners,
          builder: (context, value, child) {
            final data = value;
            if (data.isEmpty) {
              return const Center(
                child: Text('No planners'),
              );
            }

            return ListView.builder(
              itemCount: data.length,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              itemBuilder: (context, index) {
                final planner = data[index];
                return GestureDetector(
                  onLongPress: () {
                    showDialogUpdatePlanner(
                      context,
                      planner: planner,
                      onSave: (start, end, money) async {
                        final newPlanner = planner.copyWith(
                          dateStart: start,
                          dateEnd: end,
                          initialBudget: num.tryParse(money) ?? 0,
                        );
                        await _plannerRepo.savePlanner(newPlanner).then(
                          (planner) async {
                            await _updatePlannersList();
                          },
                        );
                      },
                      onDelete: () {
                        showDeletePlannerDialog(
                          context,
                          () async {
                            await _plannerRepo.deletePlanner(planner.id);
                            _updatePlannersList();
                          },
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
    );
  }

  Future<void> _updatePlannersList() async {
    final planners = await _plannerRepo.getPlanners(withPayments: true);
    _planners.value = planners;
  }

  Future _openPlanner(BuildContext context, String plannerId) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return BlocProvider(
            create: (context) {
              final bloc = PlannerBloc(
                paymentPlannerRepo: _plannerRepo,
                plannerId: plannerId,
              )..add(const PlannerEvent.computeBudget());
              return bloc;
            },
            child: const PlannerViewScreen(),
          );
        },
      ),
    );
  }
}
