import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/features/_index.dart';
import 'package:moniplan/features/feature_planners_management/widgets/planner_item_widget.dart';
import 'package:moniplan/main.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PlannersListScreen extends StatefulWidget {
  const PlannersListScreen({super.key});

  @override
  State<PlannersListScreen> createState() => _PlannersListScreenState();
}

class _PlannersListScreenState extends State<PlannersListScreen> {
  Future<List<PaymentPlanner>> _getPlanners() {
    return PaymentPlannerRepoOB(store: objectbox.store).getPlanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    _openPlanner(context, planner);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future _openPlanner(BuildContext context, PaymentPlanner planner) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return BlocProvider(
            create: (context) {
              final bloc = PaymentsManagerBloc(
                paymentPlannerRepo: PaymentPlannerRepoOB(store: objectbox.store),
              );
              bloc.add(
                PaymentsManagerEvent.computeBudget(plannerId: planner.id),
              );
              return bloc;
            },
            child: const PlannerViewScreen(),
          );
        },
      ),
    );
  }
}
