import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moniplan/bloc/budget_prediction_bloc.dart';
import 'package:moniplan/sdk/domain.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:moniplan/sdk/service/record_service.dart';
import 'package:moniplan/widget/operation_edit_widget.dart';
import 'package:dartx/dartx.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class BudgetEventEditPage extends StatefulWidget {
  final BudgetEvent? event;
  final void Function(BudgetEvent event)? onSaved;

  const BudgetEventEditPage({Key? key, required this.event, this.onSaved})
      : super(key: key);

  @override
  _BudgetEventEditPageState createState() => _BudgetEventEditPageState();

  static Future showEditModal({
    required BuildContext context,
    BudgetEvent? event,
  }) async {
    await showMaterialModalBottomSheet<void>(
      duration: Duration(milliseconds: 250),
      expand: true,
      context: context,
      enableDrag: false,
      builder: (context) {
        return BudgetEventEditPage(event: event);
      },
    );
  }
}

class _BudgetEventEditPageState extends State<BudgetEventEditPage> {
  late BudgetEvent _event;
  late final BudgetPredictionBloc _budgetPredictionBloc;
  late final BudgetEventService _budgetEventService;

  @override
  void initState() {
    final now = DateTime.now();
    _budgetPredictionBloc = context.read<BudgetPredictionBloc>();
    _budgetEventService = context.read<BudgetEventService>();

    if (widget.event != null) {
      _event =
          widget.event!.copyWith(operations: List.of(widget.event!.operations));
    } else {
      _event = BudgetEvent.single(date: now, operations: []);
    }
    super.initState();
  }

  void _saveEvent(BudgetEvent event) {
    _budgetEventService.save(_event);
    _budgetPredictionBloc.compute();
  }

  void _deleteEvent(BudgetEvent event) {
    _budgetEventService.delete(_event);
    _budgetPredictionBloc.compute();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("Delete changes?"),
              actions: [
                TextButton(
                  child: Text("Delete"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _budgetPredictionBloc.compute();
                  },
                ),
                TextButton(
                  child: Text("Save"),
                  onPressed: () {
                    _saveEvent(_event);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ).then((value) => value ?? true);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16),
            shrinkWrap: true,
            children: [
              TextButton(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_event.dateStart.date.format()),
                ),
                onPressed: () async {
                  await showDatePicker(
                    context: context,
                    initialDate: _event.dateStart,
                    firstDate: DateTime.now().subtract(Duration(days: 3650)),
                    lastDate: DateTime.now().add(Duration(days: 3650)),
                  ).then((value) {
                    setState(() {
                      _event = _event.copyWith(dateStart: value?.date);
                    });
                  });
                },
              ),
              OperationListWidget(
                operations: _event.operations,
                editable: true,
                onChanges: (operation) {
                  setState(() {
                    _event.editOperation(operation);
                  });
                },
                onDelete: (operation) {
                  setState(() {
                    _event.deleteOperation(operation);
                  });
                },
              ),
              ElevatedButton(
                child: Text("Save"),
                onPressed: () {
                  _saveEvent(_event);
                  Navigator.of(context).pop();
                },
              ),
              Offstage(
                offstage: widget.event == null,
                child: OutlinedButton(
                  child: Text("Delete"),
                  style: ButtonStyle(
                    overlayColor:
                        MaterialStateProperty.all(Colors.red.withOpacity(.12)),
                    foregroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  onPressed: () {
                    _deleteEvent(_event);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  String format({String pattern = 'dd/MM/yyyy', String? locale}) {
    if (locale != null && locale.isNotEmpty) {
      initializeDateFormatting(locale);
    }
    return DateFormat(pattern, locale).format(this);
  }
}
