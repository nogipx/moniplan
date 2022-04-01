import 'package:dartx/dartx.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:moniplan/module/operation_list/export.dart';
import 'package:moniplan/module/operation_list/service/budget_event_service_hive.dart';
import 'package:moniplan/module/operation_list/widgets/calendar_header.dart';
import 'package:moniplan/module/operation_list/widgets/calendar_item.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:sticky_infinite_list/sticky_infinite_list.dart';

class OperationsListWidget extends StatefulWidget {
  final OperationsListScreenWM operationsListScreenWM;

  const OperationsListWidget({
    required this.operationsListScreenWM,
    Key? key,
  }) : super(key: key);

  @override
  _OperationsListWidgetState createState() => _OperationsListWidgetState();
}

class _OperationsListWidgetState extends State<OperationsListWidget>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().date;

    return EntityStateNotifierBuilder<OperationsComputeResult>(
      listenableEntityState: widget.operationsListScreenWM.result,
      builder: (context, data) {
        final latestPredictionDate =
            data?.operationsByDay.keys.isNotEmpty ?? false
                ? data?.prediction.keys.last.date ?? now
                : now;
        final latestDate =
            latestPredictionDate.isBefore(now) ? now : latestPredictionDate;
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: InfiniteList(
            controller: _scrollController,
            posChildCount: 730,
            negChildCount: 730,
            anchor: latestDate.isAfter(now) ? .2 : 0,
            direction: InfiniteListDirection.multi,
            builder: (context, index) {
              final day = now.subtract(Duration(days: index)).date;
              final isDayNow = day == now;
              final isLatestDate = day == latestDate;

              if (data?.prediction.containsKey(day) ?? false || day == now) {
                return InfiniteListItem(
                  padding: EdgeInsets.only(top: isLatestDate ? 20 : 0),
                  positionAxis: HeaderPositionAxis.mainAxis,
                  headerBuilder: (context) => CalendarHeaderWidget(
                    key: ValueKey(data),
                    day: day,
                    today: now,
                    currency: CommonCurrencies().rub,
                    predictionValue: data?.prediction[day],
                  ),
                  contentBuilder: (context) {
                    final operations = data?.operationsByDay[day];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          if (operations != null)
                            CalendarItem(
                              key: ValueKey(data),
                              operations: operations,
                              showCreateOperation: isDayNow,
                              operationsListScreenWM:
                                  widget.operationsListScreenWM,
                            ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return InfiniteListItem(
                  contentBuilder: (context) => const SizedBox.shrink(),
                );
              }
            },
          ),
        );
      },
    );
  }
}

OperationsListScreenWM operationsListScreenWMFactory(BuildContext _) {
  return OperationsListScreenWM(
    OperationsListScreenModel(),
    OperationServiceHive(
      hive: GetIt.I.get(),
    ),
  );
}
