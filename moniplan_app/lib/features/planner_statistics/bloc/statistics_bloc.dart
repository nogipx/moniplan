import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_core/moniplan_core.dart';

part 'statistics_bloc.freezed.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final IStatisticsRepo repository;
  final String plannerId;

  StatisticsBloc({
    required this.repository,
    required this.plannerId,
  }) : super(const StatisticsState.initial()) {
    on<StatisticsEvent>((event, emit) async {
      await event.map(
        started: (e) => _onStarted(e, emit),
        periodChanged: (e) => _onPeriodChanged(e, emit),
        refreshRequested: (e) => _onRefreshRequested(e, emit),
      );
    });
  }

  Future<void> _onStarted(_Started event, Emitter<StatisticsState> emit) async {
    emit(const StatisticsState.loading());
    try {
      final statistics = await repository.getStatistics(plannerId: plannerId);
      emit(StatisticsState.loaded(statistics));
    } catch (e) {
      emit(StatisticsState.error(e.toString()));
    }
  }

  Future<void> _onPeriodChanged(_PeriodChanged event, Emitter<StatisticsState> emit) async {
    emit(const StatisticsState.loading());
    try {
      final statistics = await repository.getStatisticsForPeriod(
        plannerId: plannerId,
        start: event.startDate,
        end: event.endDate,
      );
      emit(StatisticsState.loaded(statistics));
    } catch (e) {
      emit(StatisticsState.error(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(_RefreshRequested event, Emitter<StatisticsState> emit) async {
    try {
      final statistics = await repository.getStatistics(plannerId: plannerId);
      emit(StatisticsState.loaded(statistics));
    } catch (e) {
      emit(StatisticsState.error(e.toString()));
    }
  }
}

@freezed
class StatisticsEvent with _$StatisticsEvent {
  const factory StatisticsEvent.started() = _Started;
  const factory StatisticsEvent.periodChanged({
    required DateTime startDate,
    required DateTime endDate,
  }) = _PeriodChanged;
  const factory StatisticsEvent.refreshRequested() = _RefreshRequested;
}

@freezed
class StatisticsState with _$StatisticsState {
  const factory StatisticsState.initial() = _Initial;
  const factory StatisticsState.loading() = _Loading;
  const factory StatisticsState.loaded(BudgetStatistics statistics) = _Loaded;
  const factory StatisticsState.error(String message) = _Error;
}
