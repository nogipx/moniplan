import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/planner/repo/_index.dart';
import 'package:moniplan_app/features/vacation_pay/mappers/map_produced_payments_use_case.dart';
import 'package:moniplan_payroll/moniplan_payroll.dart';
import 'package:uuid/uuid.dart';

part 'vacation_pay_state.dart';

/// Drives the "Отпускные" tool: pure recompute on every input change, plus
/// import of the selected produced payments into a chosen planner.
class VacationPayCubit extends Cubit<VacationPayState> {
  VacationPayCubit({
    required IPaymentsRepo paymentsRepo,
    this.targetPlannerId,
    PayrollEngine? engine,
    DateTime? today,
  })  : _paymentsRepo = paymentsRepo,
        _engine = engine ?? PayrollEngine(),
        super(VacationPayState.initial(today ?? DateTime.now())) {
    _recompute(state);
  }

  /// When set, import goes straight into this planner (no chooser).
  final String? targetPlannerId;

  final IPaymentsRepo _paymentsRepo;
  final PayrollEngine _engine;
  final _uuid = const Uuid();

  void updateGross(num value) => _recompute(state.copyInputs(grossMonthly: value));

  void updateYtd(num value) => _recompute(state.copyInputs(ytd: value));

  void updateManualAdjustment(num value) =>
      _recompute(state.copyInputs(manualAdjustment: value));

  void updatePaydays({int? first, int? second}) => _recompute(
        state.copyInputs(firstHalfDay: first, secondHalfDay: second),
      );

  void updateRange(DateTime start, DateTime end) =>
      _recompute(state.copyInputs(vacationStart: start, vacationEnd: end));

  void togglePayment(int index, {required bool enabled}) {
    if (index < 0 || index >= state.enabled.length) {
      return;
    }
    final next = [...state.enabled];
    next[index] = enabled;
    emit(state.withSelection(next));
  }

  void _recompute(VacationPayState input) {
    try {
      final profile = IncomeProfile(
        id: 'transient',
        title: '',
        grossMonthly: input.grossMonthly,
        ytdGrossAtYearStart: input.ytd,
        paySchedule: PaySchedule(
          firstHalfDay: input.firstHalfDay,
          secondHalfDay: input.secondHalfDay,
        ),
      );
      final result = _engine.compute(
        PayrollRequest.vacation(
          profile: profile,
          vacationStart: input.vacationStart,
          vacationEnd: input.vacationEnd,
          mode: CalcMode.quick,
          manualAdjustment: input.manualAdjustment,
        ),
      );
      emit(input.withResult(
        result,
        enabled: List<bool>.filled(result.payments.length, true),
      ));
    } on PayrollInputError catch (e) {
      emit(input.withError(e.message));
    } on Object catch (e) {
      emit(input.withError('$e'));
    }
  }

  /// Maps the selected payments and upserts them into [plannerId]. Returns the
  /// number of imported payments.
  Future<int> import(String plannerId) async {
    final result = state.result;
    if (result == null) {
      return 0;
    }

    final selected = <ProducedPayment>[];
    for (var i = 0; i < result.payments.length; i++) {
      if (i < state.enabled.length && state.enabled[i]) {
        selected.add(result.payments[i]);
      }
    }
    if (selected.isEmpty) {
      return 0;
    }

    final payments = MapProducedPaymentsUseCase(
      result: PayrollResult(payments: selected, breakdown: result.breakdown),
      sessionId: _uuid.v4(),
    ).call();

    for (final payment in payments) {
      await _paymentsRepo.upsert(plannerId: plannerId, payment: payment);
    }
    return payments.length;
  }
}
