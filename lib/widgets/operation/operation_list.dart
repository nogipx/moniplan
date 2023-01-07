import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/widgets/operation/operation_list_item.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'dart:math' as math;

class OperationsList extends StatelessWidget {
  final OperationsManagerState state;

  const OperationsList({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SliverList(
        delegate: OperationsListSliver(
          operations: state.operationsGenerated,
          budget: state.budget,
        ),
      ),
    );
  }
}

class OperationsListSliver extends SliverChildBuilderDelegate {
  final IList<Operation> operations;
  final IMap<Operation, double> budget;

  OperationsListSliver({
    Key? key,
    required this.operations,
    required this.budget,
  }) : super(
          (context, index) {
            final int itemIndex = index ~/ 2;
            final Widget widget;
            if (index.isEven) {
              widget =
                  _itemBuilder(operations, budget).call(context, itemIndex);
            } else {
              // widget = const SizedBox(height: 8);
              widget = _separatorBuilder(operations).call(context, itemIndex);
            }
            return widget;
          },
          semanticIndexCallback: (widget, localIndex) {
            if (localIndex.isEven) {
              return localIndex ~/ 2;
            }
            return null;
          },
          childCount: math.max(0, operations.length * 2 - 1),
        );

  static IndexedWidgetBuilder _itemBuilder(
    IList<Operation> operations,
    IMap<Operation, double> budget,
  ) {
    return (context, index) {
      final operation = operations[index];
      return OperationListItem(
        operation: operation,
        mediateSummary: budget[operation],
      );
    };
  }

  static IndexedWidgetBuilder _separatorBuilder(IList<Operation> operations) {
    return (context, index) {
      final curr = operations[index];
      final next = operations[index + 1];

      final isMonthEdge = next.date.month != curr.date.month;
      final isHalfMonth =
          !isMonthEdge && next.date.day > 15 && curr.date.day <= 15;
      final isNextDay = next.date.day != curr.date.day;

      if (isMonthEdge) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            DateFormat(DateFormat.MONTH, 'ru').format(next.date),
            style: Theme.of(context).textTheme.subtitle2,
          ),
        );
      } else if (isHalfMonth) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            '${DateFormat(DateFormat.MONTH, 'ru').format(next.date)}: медиана',
            style: Theme.of(context).textTheme.subtitle2,
          ),
        );
      } else if (isNextDay) {
        return Material(
          elevation: 20,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueGrey.withOpacity(.3),
                  Colors.blueGrey.withOpacity(.1),
                ],
              ),
            ),
            child: Text(
              DateFormat.MMMd('ru').format(next.date),
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        );
      }
      return const SizedBox(height: 8);
    };
  }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return ListView.separated(
  //     reverse: true,
  //     itemCount: operations.length,
  //     separatorBuilder: (context, index) {},
  //     itemBuilder: (context, index) {},
  //   );
  // }
}
