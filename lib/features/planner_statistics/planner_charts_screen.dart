import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_core/moniplan_core.dart';

import '_index.dart';

class PlannerChartsScreen extends StatelessWidget {
  const PlannerChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 24,
            ),
            child: Center(
              child: RotatedBox(
                quarterTurns: 1,
                child: StatisticChart(
                  budget: state.budget,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
