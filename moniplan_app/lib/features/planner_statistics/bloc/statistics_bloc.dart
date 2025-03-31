import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

part 'statistics_bloc.freezed.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final IStatisticsRepo repository;
  final String plannerId;
  final AppLog? log;

  // Флаг режима отображения
  bool _showCompletedOnly = true;

  bool get showCompletedOnly => _showCompletedOnly;

  StatisticsBloc({required this.repository, required this.plannerId, this.log})
    : super(const StatisticsState.initial()) {
    on<StatisticsEvent>((event, emit) async {
      await event.map(
        started: (e) => _onStarted(e, emit),
        periodChanged: (e) => _onPeriodChanged(e, emit),
        refreshRequested: (e) => _onRefreshRequested(e, emit),
        viewModeChanged: (e) => _onViewModeChanged(e, emit),
      );
    });
  }

  Future<void> _onStarted(_Started event, Emitter<StatisticsState> emit) async {
    log?.debug('Loading statistics for plannerId: $plannerId');
    emit(const StatisticsState.loading());
    try {
      final statistics = await repository.getStatistics(plannerId: plannerId);
      log?.debug('Statistics loaded successfully for plannerId: $plannerId');
      emit(StatisticsState.loaded(statistics, showCompletedOnly: _showCompletedOnly));
    } catch (e) {
      log?.error('Failed to load statistics for plannerId: $plannerId', error: e);
      emit(StatisticsState.error(e.toString()));
    }
  }

  Future<void> _onPeriodChanged(_PeriodChanged event, Emitter<StatisticsState> emit) async {
    log?.debug(
      'Loading statistics for plannerId: $plannerId from ${event.startDate} to ${event.endDate}',
    );
    emit(const StatisticsState.loading());
    try {
      if (event.startDate == null || event.endDate == null) {
        final statistics = await repository.getStatistics(plannerId: plannerId);
        emit(StatisticsState.loaded(statistics, showCompletedOnly: _showCompletedOnly));
        return;
      }
      final statistics = await repository.getStatisticsForPeriod(
        plannerId: plannerId,
        start: event.startDate!,
        end: event.endDate!,
      );
      log?.debug(
        'Statistics loaded successfully for plannerId: $plannerId from ${event.startDate} to ${event.endDate}',
      );
      emit(StatisticsState.loaded(statistics, showCompletedOnly: _showCompletedOnly));
    } catch (e) {
      log?.error(
        'Failed to load statistics for plannerId: $plannerId from ${event.startDate} to ${event.endDate}',
        error: e,
      );
      emit(StatisticsState.error(e.toString()));
    }
  }

  Future<void> _onViewModeChanged(_ViewModeChanged event, Emitter<StatisticsState> emit) async {
    log?.debug('Changing view mode to showCompletedOnly: ${event.showCompletedOnly}');
    _showCompletedOnly = event.showCompletedOnly;

    // Если у нас уже есть загруженные данные, просто обновляем состояние с новым режимом
    final currentState = state;
    if (currentState is _Loaded) {
      emit(currentState.copyWith(showCompletedOnly: _showCompletedOnly));
    } else {
      // Если данных еще нет, инициируем загрузку
      await _onRefreshRequested(const _RefreshRequested(), emit);
    }
  }

  Future<void> _onRefreshRequested(_RefreshRequested event, Emitter<StatisticsState> emit) async {
    try {
      final statistics = await repository.getStatistics(plannerId: plannerId);
      emit(StatisticsState.loaded(statistics, showCompletedOnly: _showCompletedOnly));
    } catch (e) {
      emit(StatisticsState.error(e.toString()));
    }
  }
}

@freezed
class StatisticsEvent with _$StatisticsEvent {
  const factory StatisticsEvent.started() = _Started;
  const factory StatisticsEvent.periodChanged({DateTime? startDate, DateTime? endDate}) =
      _PeriodChanged;
  const factory StatisticsEvent.refreshRequested() = _RefreshRequested;
  const factory StatisticsEvent.viewModeChanged({required bool showCompletedOnly}) =
      _ViewModeChanged;
}

@freezed
class StatisticsState with _$StatisticsState {
  const factory StatisticsState.initial() = _Initial;
  const factory StatisticsState.loading() = _Loading;
  const factory StatisticsState.loaded(
    BudgetStatistics statistics, {
    required bool showCompletedOnly,
  }) = _Loaded;
  const factory StatisticsState.error(String message) = _Error;
}
