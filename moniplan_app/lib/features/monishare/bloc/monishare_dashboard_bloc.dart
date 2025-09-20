import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/monishare/models/monishare_space_info.dart';
import 'package:moniplan_app/features/monishare/repository/monishare_repository.dart';

part 'monishare_dashboard_event.dart';
part 'monishare_dashboard_state.dart';

class MonishareDashboardBloc
    extends Bloc<MonishareDashboardEvent, MonishareDashboardState> {
  MonishareDashboardBloc({required MonishareRepository repository})
      : _repository = repository,
        super(MonishareDashboardState.initial(isConnected: repository.isConnected)) {
    on<MonishareDashboardStarted>(_onStarted);
    on<MonishareDashboardRefreshRequested>(_onRefreshRequested);
    on<MonishareDashboardConnectionRequested>(_onConnectionRequested);
    on<_MonishareDashboardStatusChanged>(_onStatusChanged);
    on<MonishareDashboardMessageCleared>(_onMessageCleared);

    _statusSubscription = _repository.statusStream.listen((isConnected) {
      add(_MonishareDashboardStatusChanged(isConnected: isConnected));
    });
  }

  final MonishareRepository _repository;
  StreamSubscription<bool>? _statusSubscription;

  Future<void> _onStarted(
    MonishareDashboardStarted event,
    Emitter<MonishareDashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, message: null, errorMessage: null));
    await _repository.ensureServiceStarted();
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    MonishareDashboardRefreshRequested event,
    Emitter<MonishareDashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, message: null, errorMessage: null));
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<MonishareDashboardState> emit) async {
    try {
      final planners = await _repository.loadPlanners();
      final spaces = <String, MonishareSpaceInfo>{};
      for (final planner in planners) {
        final space = await _repository.loadSpace(planner.id);
        if (space != null) {
          spaces[planner.id] = space;
        }
      }
      emit(
        state.copyWith(
          isLoading: false,
          planners: planners,
          spaces: spaces,
          errorMessage: null,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Не удалось загрузить данные: $error',
        ),
      );
    }
  }

  Future<void> _onConnectionRequested(
    MonishareDashboardConnectionRequested event,
    Emitter<MonishareDashboardState> emit,
  ) async {
    if (state.isConnecting) {
      return;
    }

    emit(state.copyWith(isConnecting: true, message: null, errorMessage: null));
    try {
      await _repository.ensureServiceStarted();
      emit(state.copyWith(isConnecting: false));
    } on Object catch (error) {
      emit(
        state.copyWith(
          isConnecting: false,
          errorMessage: 'Не удалось запустить транспорт: $error',
        ),
      );
    }
  }

  void _onStatusChanged(
    _MonishareDashboardStatusChanged event,
    Emitter<MonishareDashboardState> emit,
  ) {
    emit(state.copyWith(isConnected: event.isConnected));
  }

  void _onMessageCleared(
    MonishareDashboardMessageCleared event,
    Emitter<MonishareDashboardState> emit,
  ) {
    emit(state.copyWith(message: null, errorMessage: null));
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
