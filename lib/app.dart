import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/main.dart';
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
  late final PaymentsManagerBloc _bloc;

  @override
  void initState() {
    _bloc = PaymentsManagerBloc();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPlanner(testPlannerId).then(
      (value) {
        if (value != null) {
          _bloc.add(
            PaymentsManagerEvent.computeBudget(planner: value),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _bloc,
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
