import 'package:flutter/material.dart';
import 'package:moniplan/features/monisync/screens/monisync_screen.dart';
import 'package:moniplan/features/planners_list//_index.dart';
import 'package:moniplan/theme/_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeChanger(
      initialBrightness: ThemeBrightness.light,
      storage: ThemeChangerStorageSharedPreferences(
        sharedPreferences: widget.sharedPreferences,
      ),
      onChangeTheme: (brightness) {
        MoniplanColors.brightness = brightness;
      },
      builder: (context, brightness) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: const Text('Планеры'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return const PlannersListScreen();
                              }),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          child: const Text('MoniSync'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return const MonisyncScreen();
                              }),
                            );
                          },
                        ),
                        // const SizedBox(height: 16),
                        // ElevatedButton(
                        //   child: const Text('Справочник платежей'),
                        //   onPressed: () {
                        //     Navigator.of(context).push(
                        //       MaterialPageRoute(builder: (context) {
                        //         return const PaymentsReferenceScreen();
                        //       }),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
