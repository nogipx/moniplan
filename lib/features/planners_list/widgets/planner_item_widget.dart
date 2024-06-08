import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PlannerItemWidget extends StatelessWidget {
  const PlannerItemWidget({
    super.key,
    required this.planner,
    this.onPressed,
  });

  final PaymentPlanner planner;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(planner.id),
            ],
          ),
        ),
      ),
    );
  }
}
