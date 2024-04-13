import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/main.dart';
import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/_index.dart';

class MoniplanApp extends StatefulWidget {
  const MoniplanApp({
    super.key,
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  @override
  State<MoniplanApp> createState() => _MoniplanAppState();
}

class _MoniplanAppState extends State<MoniplanApp> {
  @override
  void initState() {
    super.initState();
    // _clear();
    // _savePlanner(currentRequest);
    // _getPlanner('ae40c540-7ce3-4754-a501-beb40bc89a9c');
  }

  _clear() {
    objectbox.store.box<PaymentComposedDaoOB>().removeAll();
    objectbox.store.box<PaymentPlannerDaoOB>().removeAll();
  }

  _savePlanner(PaymentPlanner planner) {
    final mapper = PlannerMapper();
    final generated = GeneratePlannerUseCase(
      args: GeneratePlannerUseCaseArgs(
        payments: currentRequest.payments,
        dateStart: currentRequest.dateStart,
        dateEnd: currentRequest.dateEnd,
        initialBudget: currentRequest.initialBudget,
      ),
    ).run();

    final dao = mapper.toDto(generated.planner);
    objectbox.store.box<PaymentPlannerDaoOB>().put(dao);
  }

  PaymentPlanner? _getPlanner(String id) {
    final mapper = PlannerMapper();
    final dao = objectbox.store
        .box<PaymentPlannerDaoOB>()
        .query(
          PaymentPlannerDaoOB_.plannerId.equals(id),
        )
        .build()
        .findUnique();

    if (dao != null) {
      final planner = mapper.toDomain(dao);
      return planner;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final planner = _getPlanner('ae40c540-7ce3-4754-a501-beb40bc89a9c');
            final bloc = PaymentsManagerBloc();
            if (planner != null) {
              bloc.computeBudget(
                PaymentsManagerEvent.computeBudget(
                  planner: planner,
                ),
              );
            }
            return bloc;
          },
        ),
      ],
      child: ThemeChanger(
        storage: ThemeChangerStorageSharedPreferences(
          sharedPreferences: widget.sharedPreferences,
        ),
        onChangeTheme: (brightness) {
          MoniplanColors.brightness = brightness;
        },
        builder: (context) {
          return const MaterialApp(
            home: PlannerViewScreen(),
          );
        },
      ),
    );
  }
}
