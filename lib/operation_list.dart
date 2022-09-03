import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';

class OperationList extends StatelessWidget {
  final List<Operation> operations;

  const OperationList({
    Key? key,
    required this.operations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: operations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final operation = operations[index];
        return OperationListItem(operation: operation);
      },
    );
  }
}

class OperationListItem extends StatelessWidget {
  final Operation operation;

  const OperationListItem({
    Key? key,
    required this.operation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
