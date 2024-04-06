import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan/widgets/operation/operation_list_item.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'dart:math' as math;

class OperationsListSliver extends SliverChildBuilderDelegate {
  final IList<Operation> operations;
  final IMap<Operation, double> budget;

  OperationsListSliver({
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
                    daySeparator(operations[itemIndex].date),
                    widget,
                  ],
                );
              }
            } else {
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
            daySeparator(next.date),
          ],
        );
      } else if (isHalfMonth) {
        return Column(
          children: [
            medianSeparator(next.date),
            daySeparator(next.date),
          ],
        );
      } else if (isNextDay) {
        return daySeparator(next.date);
      }
      return const SizedBox(height: 2);
    };
  }

  static Widget daySeparator(DateTime date) {
    return Builder(builder: (context) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        decoration: const BoxDecoration(
          color: MoniplanColors.white,
        ),
        child: Material(
          elevation: 3,
          shadowColor: MoniplanColors.inactiveBackgroundColor,
          color: MoniplanColors.lightBlueColor,
          borderRadius: MoniplanConst.borderRadius50,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                child: Text(
                  DateFormat.MMMMd('ru').format(date),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: MoniplanColors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget monthSeparator(DateTime date) {
    return Builder(builder: (context) {
      return Container(
        alignment: Alignment.bottomLeft,
        color: MoniplanColors.white,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          DateFormat(DateFormat.MONTH, 'ru').format(date).capitalize(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: MoniplanColors.primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
    });
  }

  static Widget medianSeparator(DateTime date) {
    return Builder(
      builder: (context) {
        return Container(
          alignment: Alignment.bottomCenter,
          color: MoniplanColors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Середина ${DateFormat(DateFormat.MONTH, 'ru').format(date)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: MoniplanColors.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      },
    );
  }
}
