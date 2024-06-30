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

  @override
  void initState() {
    _plannerRepo = PlannerRepoDrift(db: db);
    super.initState();
  }

  Future<List<PaymentPlanner>> _getPlanners() {
    return _plannerRepo.getPlanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: dbInspectorFloatingActionButton,
      body: SafeArea(
        child: FutureBuilder(
          future: _getPlanners(),
          builder: (context, snapshot) {
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return const Center(
                child: Text('No planners'),
              );
            }

            return ListView.builder(
              itemCount: data.length,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              itemBuilder: (context, index) {
                final planner = data[index];
                return PlannerItemWidget(
                  planner: planner,
                  onPressed: () {
                    _openPlanner(context, planner.id);
                  },
                );
              },
            );
          },
        ),
      ),
    );
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
