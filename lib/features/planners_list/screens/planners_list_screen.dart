import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/features/_common/db_view_floating_button.dart';
import 'package:moniplan/features/payment_planner/_index.dart';
import 'package:moniplan/features/planners_list/_index.dart';
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
    _getPlanners();
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
          onPressed: () {},
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
                    showDeletePlannerDialog(
                      context,
                      () async {
                        await _plannerRepo.deletePlanner(planner.id);
                        _getPlanners();
                      },
                    );
                  },
                  child: PlannerItemWidget(
                    planner: planner,
                    onPressed: () {
                      _openPlanner(context, planner.id);
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

  Future<void> _getPlanners() async {
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

void showDeletePlannerDialog(BuildContext context, VoidCallback onDelete) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Planner'),
        content:
            Text('Are you sure you want to delete this planner? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(); // Вызываем функцию удаления
              Navigator.of(context).pop(); // Закрываем диалог
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Меняем цвет кнопки на красный
            ),
          ),
        ],
      );
    },
  );
}
