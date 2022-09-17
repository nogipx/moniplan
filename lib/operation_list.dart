import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/money_colored_widget.dart';
import 'package:moniplan/theme/colors.dart';
import 'package:moniplan/useful/grayscale.dart';
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
          reverse: true,
          itemCount: operations.length,
          separatorBuilder: (context, index) {
            final curr = operations[index];
            final next = operations[index + 1];

            final isMonthEdge = next.date.month != curr.date.month;
            final isHalfMonth =
                !isMonthEdge && next.date.day > 15 && curr.date.day <= 15;

            if (isMonthEdge) {
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  DateFormat(DateFormat.MONTH, 'ru').format(curr.date),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              );
            } else if (isHalfMonth) {
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  '${DateFormat(DateFormat.MONTH, 'ru').format(curr.date)}: медиана',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              );
            }
            return const SizedBox(height: 8);
          },
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

    final repeatWidget = operation.isRepeat && operation.isNotParent
        ? Row(
            children: [
              const Icon(
                Icons.event_repeat_rounded,
                size: 18,
                color: MoniplanColors.disabledColor,
              ),
              const SizedBox(width: 4),
              Text(operation.repeat.shortName)
            ],
          )
        : const SizedBox();

    return Grayscale(
      grayscale: !operation.enabled,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                // if (operation.isParent) ...[
                //   Container(
                //     height: 6,
                //     width: 6,
                //     decoration: const BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Colors.blueAccent,
                //     ),
                //   ),
                //   const SizedBox(width: 8),
                // ],
                Text(
                  operation.note,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, 'RU')
                      .format(operation.date),
                  style: Theme.of(context).textTheme.caption?.copyWith(
                        fontSize: 14,
                      ),
                ),
                // const SizedBox(width: 8),
                // originalWidget,
                const SizedBox(width: 8),
                repeatWidget
              ],
            ),
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
                  color: MoniplanColors.disabledColor,
                ),
                const SizedBox(width: 4),
                budgetPredictWidget,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
