import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:moniplan/money_colored_widget.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OperationsList extends StatelessWidget {
  final OperationsManagerBloc? bloc;

  const OperationsList({
    Key? key,
    this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OperationsManagerBloc, OperationsManagerState>(
      bloc: null,
      builder: (context, state) {
        final operations = state.maybeMap<IList<Operation>>(
          budgetComputed: (v) => v.operationsGenerated,
          orElse: () => const IListConst([]),
        );

        final budget = state.maybeMap<IMap<Operation, double>>(
          budgetComputed: (v) => v.budget,
          orElse: () => const IMapConst({}),
        );

        return ListView.separated(
          itemCount: operations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final operation = operations[index];
            return OperationListItem(
              operation: operation,
              mediateSummary: budget[operation],
            );
          },
        );
      },
    );
  }
}

class OperationListItem extends StatelessWidget {
  final Operation operation;
  final double? mediateSummary;

  const OperationListItem({
    Key? key,
    required this.operation,
    this.mediateSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final budgetPredictWidget = mediateSummary != null
        ? MoneyColoredWidget(
            value: mediateSummary,
            currency: operation.currency,
            showPlusSign: false,
          )
        : const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          Text(operation.date.toLocal().toIso8601String()),
          const SizedBox(height: 8),
          Row(
            children: [
              MoneyColoredWidget(
                value: operation.normalizedValue,
                currency: operation.currency,
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_right,
                size: 20,
              ),
              const SizedBox(width: 4),
              budgetPredictWidget,
            ],
          ),
        ],
      ),
    );
  }
}
