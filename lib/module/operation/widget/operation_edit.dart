import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartx/dartx.dart';
import 'package:moniplan/_sdk/domain.dart';
import 'package:moniplan/_sdk/domain/currency.dart';
import 'package:moniplan/bloc/budget_prediction_bloc.dart';
import 'package:provider/provider.dart';

class OperationEditWidget extends StatefulWidget {
  final Operation? initialData;

  const OperationEditWidget({Key? key, this.initialData}) : super(key: key);

  @override
  _OperationEditWidgetState createState() => _OperationEditWidgetState();
}

class _OperationEditWidgetState extends State<OperationEditWidget> {
  late final TextEditingController _title;
  late final TextEditingController _money;
  late final TextEditingController _actualMoney;
  late Operation _operation;

  @override
  void initState() {
    _operation = widget.initialData?.copyWith() ??
        Operation.create(
          expectedValue: 0,
          reason: "",
          date: DateTime.now(),
          currency: CommonCurrencies().rub,
        );

    _money = TextEditingController(
        text: _operation.expectedValue == 0
            ? null
            : _operation.expectedValue.isWhole
                ? _operation.expectedValue.toInt().toString()
                : _operation.expectedValue.toString())
      ..addListener(() {
        setState(() {
          _operation = _operation.copyWith(
            expectedValue: double.tryParse(_money.text.trim()),
          );
        });
      });
    _actualMoney = TextEditingController(
        text: _operation.actualValue == 0 || _operation.actualValue == null
            ? null
            : _operation.actualValue!.isWhole
                ? _operation.actualValue!.toInt().toString()
                : _operation.actualValue.toString())
      ..addListener(() {
        // print(_actualMoney.text);
        // print(double.tryParse(_actualMoney.text));
        setState(() {
          final newOperation = _operation.copyWith(
            actualValue: double.tryParse(_actualMoney.text.trim()),
          );
          _operation = newOperation;
        });
        print(_operation.actualValue);
      });

    _title = TextEditingController()
      ..text = _operation.reason
      ..addListener(() {
        _operation = _operation.copyWith(reason: _title.text);
      });

    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _money.dispose();
    _actualMoney.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
          child: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      horizontal: 16,
                      vertical: 16,
                    ),
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
                    FilteringTextInputFormatter.allow(RegExp(r"[\d. -]*"))
                  ],
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Money value",
                    hintStyle: textStyle.apply(color: Colors.black38),
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        _operation.currency.intlSymbol,
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
            Builder(
              builder: (context) {
                final textStyle = Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.normal);
                return TextFormField(
                  controller: _actualMoney,
                  keyboardType: TextInputType.number,
                  style: textStyle,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[\d. -]*"))
                  ],
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Actual money value",
                    hintStyle: textStyle.apply(color: Colors.black38),
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        _operation.currency.intlSymbol,
                        style: textStyle.apply(color: Colors.black87),
                      ),
                    ),
                    suffix: InkWell(
                      child: Icon(Icons.clear, color: Colors.black45),
                      onTap: () {
                        _actualMoney.clear();
                        _operation = _operation.copyWithNull(actualValue: true);
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
            TextButton(
              child: Text(_operation.date.toString()),
              onPressed: () async {
                await showDatePicker(
                  context: context,
                  initialDate: _operation.date,
                  firstDate: DateTime.now().subtract(Duration(days: 3650)),
                  lastDate: DateTime.now().add(Duration(days: 3650)),
                ).then((value) {
                  setState(() {
                    _operation = _operation.copyWith(date: value?.date);
                  });
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
                    Navigator.of(context).pop(_operation);
                  },
                ),
              ],
            ),
            if (widget.initialData != null)
              OutlinedButton.icon(
                icon: Icon(Icons.remove),
                label: Text("Удалить"),
                onPressed: () {
                  context.read<BudgetPredictionBloc>().compute(
                      (context.read<OperationService>()
                            ..delete(widget.initialData!))
                          .getAll());
                  Navigator.pop(context);
                },
              )
          ],
        ),
      )),
    );
  }
}
