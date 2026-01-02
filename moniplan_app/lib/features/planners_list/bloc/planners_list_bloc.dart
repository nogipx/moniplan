import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moniplan_app/core/_index.dart';
import 'package:moniplan_app/features/planner/repo/_index.dart';

part 'planners_list_event.dart';
part 'planners_list_state.dart';

class PlannersListBloc extends Bloc<PlannersListEvent, PlannersListState> {
  PlannersListBloc({
    required IPlannersRepo plannersRepo,
    required IPaymentsRepo paymentsRepo,
    required IPlannerActualInfoRepo actualInfoRepo,
    required IPlannerSettingsRepo settingsRepo,
  }) : _plannersRepo = plannersRepo,
       _paymentsRepo = paymentsRepo,
       _actualInfoRepo = actualInfoRepo,
       _settingsRepo = settingsRepo,
       super(const PlannersListState()) {
    on<PlannersListLoad>(_onLoad);
    on<PlannersListAdd>(_onAdd);
    on<PlannersListUpdate>(_onUpdate);
    on<PlannersListDelete>(_onDelete);
    on<PlannersListToggleCurrent>(_onToggleCurrent);
  }

  final IPlannersRepo _plannersRepo;
  final IPaymentsRepo _paymentsRepo;
  final IPlannerActualInfoRepo _actualInfoRepo;
  final IPlannerSettingsRepo _settingsRepo;

  Future<void> _onLoad(
    PlannersListLoad event,
    Emitter<PlannersListState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    final planners = await _plannersRepo.list(limit: 1000);
    final currentPlannerId = (await _settingsRepo.getSettings())?.currentPlannerId;
    final plannersWithActual = <Planner>[];
    for (final planner in planners) {
      final actualInfo = await _actualInfoRepo.get(planner.id);
      plannersWithActual.add(planner.copyWith(actualInfo: actualInfo));
    }
    emit(
      state.copyWith(
        planners: plannersWithActual,
        currentPlannerId: currentPlannerId,
        loading: false,
      ),
    );
  }

  Future<void> _onAdd(
    PlannersListAdd event,
    Emitter<PlannersListState> emit,
  ) async {
    await _plannersRepo.upsert(event.planner);
    await _onLoad(const PlannersListLoad(), emit);
  }

  Future<void> _onUpdate(
    PlannersListUpdate event,
    Emitter<PlannersListState> emit,
  ) async {
    await _plannersRepo.upsert(event.planner);
    await _onLoad(const PlannersListLoad(), emit);
  }

  Future<void> _onDelete(
    PlannersListDelete event,
    Emitter<PlannersListState> emit,
  ) async {
    final payments = await _paymentsRepo.listByPlanner(event.plannerId);
    if (payments.isNotEmpty) {
      await _paymentsRepo.bulkDelete(
        plannerId: event.plannerId,
        ids: payments.map((p) => p.paymentId).toList(),
      );
    }
    await _actualInfoRepo.delete(event.plannerId);
    final settings = await _settingsRepo.getSettings();
    if (settings?.currentPlannerId == event.plannerId) {
      await _settingsRepo.deleteSettings();
    }
    await _plannersRepo.delete(event.plannerId);
    await _onLoad(const PlannersListLoad(), emit);
  }

  Future<void> _onToggleCurrent(
    PlannersListToggleCurrent event,
    Emitter<PlannersListState> emit,
  ) async {
    final settings = await _settingsRepo.getSettings();
    final isCurrent = settings?.currentPlannerId == event.planner.id;
    if (isCurrent) {
      await _settingsRepo.deleteSettings();
      emit(state.copyWith(currentPlannerId: null));
    } else {
      final next = (settings ?? _settingsRepo.createDefaultSettings()).copyWith(
        currentPlannerId: event.planner.id,
      );
      await _settingsRepo.saveSettings(next);
      emit(state.copyWith(currentPlannerId: event.planner.id));
    }
  }
}
