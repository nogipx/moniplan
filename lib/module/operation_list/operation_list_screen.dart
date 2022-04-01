import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:moniplan/module/operation_list/export.dart';
import 'package:moniplan/module/operation_list/widgets/calendar_widget.dart';
import 'package:moniplan/module/operation_list/widgets/operation_list_item.dart';

class OperationListScreen extends ElementaryWidget<OperationsListScreenWM> {
  const OperationListScreen({
    WidgetModelFactory factory = operationsListFactoryWM,
    Key? key,
  }) : super(factory, key: key);

  @override
  Widget build(OperationsListScreenWM wm) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onDoubleTap: wm.onCreateOperation,
          child: OperationsListWidget(
            operationsListScreenWM: wm,
          ),
        ),
      ),
    );
  }
}

OperationsListScreenWM operationsListFactoryWM(BuildContext _) {
  return OperationsListScreenWM(
    OperationsListScreenModel(),
    GetIt.I.get(),
  );
}
