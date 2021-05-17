import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartx/dartx.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/sdk/domain/currency.dart';

class OperationEditWidget extends StatefulWidget {
  final Operation? initialData;

  const OperationEditWidget({Key? key, this.initialData}) : super(key: key);

  @override
  _OperationEditWidgetState createState() => _OperationEditWidgetState();
}

class _OperationEditWidgetState extends State<OperationEditWidget> {
  late final TextEditingController _title;
  late final TextEditingController _money;
  late ValueNotifier<Operation> _operation;

  @override
  void initState() {
    _operation = ValueNotifier(widget.initialData?.copyWith() ??
        Operation.outcome(
          value: 0,
          reason: "",
          date: DateTime.now(),
          currency: CommonCurrencies().rub,
        ));

    _money = TextEditingController(
        text: _operation.value.value == 0
            ? null
            : _operation.value.value.isWhole
                ? _operation.value.value.toInt().toString()
                : _operation.value.value.toString())
      ..addListener(() {
        _operation.value = _operation.value.copyWith(
          value: double.tryParse(_money.text.trim()),
        );
      });

    _title = TextEditingController()
      ..text = _operation.value.reason
      ..addListener(() {
        _operation.value = _operation.value.copyWith(reason: _title.text);
      });

    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _money.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ValueListenableBuilder<Operation>(
          valueListenable: _operation,
          builder: (context, result, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    final textStyle = Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.normal);
                    return TextFormField(
                      controller: _title,
                      style: textStyle,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Operation title",
                        hintStyle: textStyle.apply(color: Colors.black38),
                        hintMaxLines: 2,
                        suffix: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: InkWell(
                            child: Icon(Icons.clear, color: Colors.black45),
                            onTap: () {
                              _title.clear();
                            },
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    );
                  },
                ),
                Divider(height: 0),
                Builder(
                  builder: (context) {
                    final textStyle = Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.normal);
                    return TextFormField(
                      controller: _money,
                      keyboardType: TextInputType.number,
                      style: textStyle,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[\d. ]"))
                      ],
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Money value",
                        hintStyle: textStyle.apply(color: Colors.black38),
                        prefix: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            result.currency.intlSymbol,
                            style: textStyle.apply(color: Colors.black87),
                          ),
                        ),
                        suffix: InkWell(
                          child: Icon(Icons.clear, color: Colors.black45),
                          onTap: () {
                            _money.clear();
                          },
                        ),
                        labelStyle: textStyle.apply(color: Colors.black87),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    );
                  },
                ),
                Divider(height: 0),
                ToggleButtons(
                  children: [
                    Icon(Icons.remove),
                    Icon(Icons.add),
                  ],
                  isSelected: [
                    result.type == OperationType.Outcome,
                    result.type == OperationType.Income,
                  ],
                  onPressed: (type) {
                    _operation.value = result.copyWith(
                      type: type == 0
                          ? OperationType.Outcome
                          : OperationType.Income,
                    );
                  },
                ),
                Divider(height: 0),
                TextButton(
                  child: Text(result.date.toString()),
                  onPressed: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: result.date,
                      firstDate: DateTime.now().subtract(Duration(days: 3650)),
                      lastDate: DateTime.now().add(Duration(days: 3650)),
                    ).then((value) {
                      _operation.value = result.copyWith(date: value?.date);
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Text("Discard"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text("Save"),
                      onPressed: () {
                        Navigator.of(context).pop(_operation.value);
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
