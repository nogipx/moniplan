import 'package:flutter/material.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/widget/operation_widgets.dart';

class OperationListWidget extends StatefulWidget {
  final List<Operation> operations;
  final Color textColor;
  final bool editable;
  final void Function(Operation operation)? onChanges;
  final void Function(Operation operation)? onDelete;

  const OperationListWidget({
    Key? key,
    required this.operations,
    this.textColor = Colors.black87,
    this.editable = false,
    this.onChanges,
    this.onDelete,
  }) : super(key: key);

  @override
  _OperationListWidgetState createState() => _OperationListWidgetState();
}

class _OperationListWidgetState extends State<OperationListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.separated(
          shrinkWrap: true,
          primary: false,
          separatorBuilder: (_, __) => SizedBox(height: 8),
          itemCount: widget.operations.length,
          itemBuilder: (context, index) {
            final operation = widget.operations[index];
            return Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.editable
                    ? () async {
                        await showDialog<Operation>(
                          context: context,
                          builder: (context) {
                            return OperationEditDialog(
                              operation: operation,
                            );
                          },
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              widget.onChanges?.call(value);
                            });
                          }
                        });
                      }
                    : null,
                child: Row(
                  children: [
                    Offstage(
                      offstage: !widget.editable,
                      child: Checkbox(
                        value: operation.enabled,
                        onChanged: (enabled) {
                          setState(() {
                            if (enabled != null) {
                              widget.onChanges?.call(
                                operation.copyWith(enabled: enabled),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: OperationWidget(
                        operation: operation,
                        textColor: widget.textColor,
                      ),
                    ),
                    Offstage(
                      offstage: !widget.editable,
                      child: IconButton(
                        iconSize: 20,
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            widget.onDelete?.call(operation);
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
        Offstage(
          offstage: !widget.editable,
          child: TextButton(
            child: Text("Add operation"),
            onPressed: () async {
              await showDialog<Operation>(
                context: context,
                builder: (context) {
                  return OperationEditDialog();
                },
              ).then((value) {
                if (value != null) {
                  setState(() {
                    widget.onChanges?.call(value);
                  });
                }
              });
            },
          ),
        )
      ],
    );
  }
}

class OperationEditDialog extends StatefulWidget {
  final Operation? operation;

  const OperationEditDialog({
    Key? key,
    this.operation,
  }) : super(key: key);

  @override
  _OperationEditDialogState createState() => _OperationEditDialogState();
}

class _OperationEditDialogState extends State<OperationEditDialog> {
  late Operation _operation;
  late List<bool> _selectedOperationType;
  late TextEditingController _value;
  late TextEditingController _reason;

  @override
  void initState() {
    _operation = widget.operation ??
        Operation.outcome(
          value: widget.operation?.value ?? 0,
          reason: widget.operation?.reason ?? "",
        );
    _selectedOperationType = [
      widget.operation?.type == OperationType.Outcome,
      widget.operation?.type == OperationType.Income,
    ];
    _reason = TextEditingController()..text = _operation.reason;
    _value = TextEditingController()..text = _operation.value.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Save"),
          onPressed: () {
            Navigator.of(context).pop(
              _operation.copyWith(
                value: double.tryParse(_value.text),
                reason: _reason.text,
                type: _selectedOperationType[0]
                    ? OperationType.Outcome
                    : OperationType.Income,
              ),
            );
          },
        ),
      ],
    );
  }
}
