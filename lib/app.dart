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
    final t = objectbox.store.box<PaymentComposedDaoOB>().getAll();

    final mapper = PaymentMapper();
    final dao = mapper.toDto(currentRequest.payments.first);
    objectbox.store.box<PaymentComposedDaoOB>().put(dao);

    final dtt = objectbox.store.box<PaymentComposedDaoOB>().getAll().map(mapper.toDomain).toList();
    print(t);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PaymentsManagerBloc()
            ..computeBudget(
              PaymentsManagerEvent.computeBudget(
                planner: currentRequest,
              ),
            ),
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
