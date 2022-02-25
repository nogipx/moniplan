import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moniplan/module/operation/export.dart';
import 'package:sticky_infinite_list/sticky_infinite_list.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:dartx/dartx.dart';

class OperationsListWidget extends ConsumerStatefulWidget {
  const OperationsListWidget({Key? key, required this.eventsByDay})
      : super(key: key);

  final Map<DateTime, List<Operation>> eventsByDay;

  @override
  _OperationsListWidgetState createState() => _OperationsListWidgetState();
}

class _OperationsListWidgetState extends ConsumerState<OperationsListWidget>
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
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now().date;
    final predictionCubit = ref.watch(provider)
    return BlocBuilder<BudgetPredictionCubit, BudgetPredictionState>(
      builder: (context, state) {
        final latestPredictionDate =
            state is PredictionSuccess && state.operations.keys.isNotEmpty
                ? state.predictions.keys.last.date
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
            builder: (BuildContext context, int index) {
              final day = now.subtract(Duration(days: index)).date;
              final isDayNow = day == now;
              final isLatestDate = day == latestDate;

              if (widget.eventsByDay.containsKey(day) || day == now) {
                return InfiniteListItem(
                  padding: EdgeInsets.only(top: isLatestDate ? 20 : 0),
                  positionAxis: HeaderPositionAxis.mainAxis,
                  headerBuilder: (context) => CalendarHeaderWidget(
                    key: ValueKey(state),
                    day: day,
                    today: now,
                    currency: CommonCurrencies().rub,
                    predictionValue: state is PredictionSuccess
                        ? state.predictions[day]
                        : null,
                  ),
                  contentBuilder: (context) {
                    if (state is PredictionSuccess) {
                      final prediction = state.operations[day];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          children: [
                            if (prediction != null)
                              CalendarItem(
                                key: ValueKey(state),
                                operations: state.operations[day] ?? [],
                                showCreateOperation: isDayNow,
                              ),
                          ],
                        ),
                      );
                    } else if (state is PredictionInProgress) {
                      return CircularProgressIndicator();
                    } else {
                      return Text("ERROR");
                    }
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
