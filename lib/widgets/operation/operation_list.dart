import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
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
            Widget widget;
            if (index.isEven) {
              widget =
                  _itemBuilder(operations, budget).call(context, itemIndex);
              if (index == 0) {
                widget = Column(
                  children: [
                    regularSeparator(operations[itemIndex].date),
                    widget,
                  ],
                );
              }
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
        return Column(
          children: [
            monthSeparator(next.date),
            regularSeparator(next.date),
          ],
        );
      } else if (isHalfMonth) {
        return Column(
          children: [
            medianSeparator(next.date),
            regularSeparator(next.date),
          ],
        );
      } else if (isNextDay) {
        return regularSeparator(next.date);
      }
      return const SizedBox(height: 2);
    };
  }

  static Widget regularSeparator(DateTime date) {
    return Builder(builder: (context) {
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
            DateFormat.MMMd('ru').format(date),
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );
    });
  }

  static Widget monthSeparator(DateTime date) {
    return Builder(builder: (context) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey.withOpacity(.7),
              Colors.blueGrey.withOpacity(.5),
            ],
          ),
        ),
        child: Text(
          DateFormat(DateFormat.MONTH, 'ru').format(date),
          style: Theme.of(context).textTheme.subtitle2?.copyWith(
                color: Colors.white,
              ),
        ),
      );
    });
  }

  static Widget medianSeparator(DateTime date) {
    return Builder(
      builder: (context) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blueGrey.withOpacity(.7),
                Colors.blueGrey.withOpacity(.5),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            '${DateFormat(DateFormat.MONTH, 'ru').format(date)}: медиана',
            style: Theme.of(context).textTheme.subtitle2?.copyWith(
                  color: Colors.white,
                ),
          ),
        );
      },
    );
  }
}
