import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moniplan/app/injector.dart';
// import 'package:moniplan/hive/domain_adapter.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/app/export.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive.registerAdapter(OperationTypeAdapter());
  Hive.registerAdapter(OperationAdapter());
  // Hive.registerAdapter<Prediction>(PredictionAdapter());
  await Hive.initFlutter();
  runApp(
    Injector(
      operationHive: await Hive.openBox<Operation>(OperationService.key),
      child: MoniplanResponsiveApp(),
    ),
  );
}
