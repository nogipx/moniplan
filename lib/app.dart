import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/our_budget/_index.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/feature_budget_predict/_index.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PaymentsManagerBloc()..computeBudget(currentRequest),
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
