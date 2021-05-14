import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moniplan/sdk/domain.dart';

import 'package:dartx/dartx.dart';

class OperationEditDialog extends StatefulWidget {
  final Operation? initialData;

  const OperationEditDialog({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  _OperationEditDialogState createState() => _OperationEditDialogState();

  static Future<Operation?> showEdit({
    required BuildContext context,
    Operation? initialData,
  }) async {
    return await showMaterialModalBottomSheet<Operation?>(
      duration: Duration(milliseconds: 250),
      expand: true,
      enableDrag: false,
      context: context,
      builder: (context) {
        return OperationEditDialog(initialData: initialData);
      },
    );
  }
}

class _OperationEditDialogState extends State<OperationEditDialog> {
  late Operation _data;
  late List<bool> _selectedOperationType;
  late TextEditingController _value;
  late TextEditingController _reason;

  @override
  void initState() {
    _data = widget.initialData ??
        Operation.outcome(
          date: DateTime.now().date,
          value: widget.initialData?.value ?? 0,
          reason: widget.initialData?.reason ?? "",
        );
    _selectedOperationType = [
      widget.initialData?.type == OperationType.Outcome,
      widget.initialData?.type == OperationType.Income,
    ];
    _reason = TextEditingController()..text = _data.reason;
    _value = TextEditingController()..text = _data.value.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_data.date.format()),
            ),
            onPressed: () async {
              await showDatePicker(
                context: context,
                initialDate: _data.date.date,
                firstDate: DateTime.now().subtract(Duration(days: 3650)),
                lastDate: DateTime.now().add(Duration(days: 3650)),
              ).then((value) {
                setState(() {
                  _data = _data.copyWith(date: value?.date);
                });
              });
            },
          ),
          TextFormField(
            controller: _reason,
            decoration: InputDecoration(
              hintText: "Reason",
            ),
          ),
          SizedBox(height: 8),
          ToggleButtons(
            children: [
              Icon(Icons.remove),
              Icon(Icons.add),
            ],
            isSelected: _selectedOperationType,
            onPressed: (type) {
              setState(() {
                _selectedOperationType = _selectedOperationType
                    .asMap()
                    .entries
                    .map((e) => e.key == type)
                    .toList();
              });
            },
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _value,
            decoration: InputDecoration(
              hintText: "Value",
              suffix: Text("RUB"),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Discard"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Save"),
          onPressed: () {
            Navigator.of(context).pop(_result);
          },
        ),
      ],
    );
  }

  Operation get _result {
    return _data.copyWith(
      value: double.tryParse(_value.text),
      reason: _reason.text,
      type: _selectedOperationType[0]
          ? OperationType.Outcome
          : OperationType.Income,
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
