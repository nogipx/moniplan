import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/module/operation/cubit/operation_edit_cubit.dart';
import 'package:provider/provider.dart';

class OperationEditScreen extends StatefulWidget {
  final OperationEditCubit operationEditCubit;

  const OperationEditScreen({
    Key? key,
    required this.operationEditCubit,
  }) : super(key: key);

  @override
  _OperationEditScreenState createState() => _OperationEditScreenState();
}

class _OperationEditScreenState extends State<OperationEditScreen> {
  late final OperationEditCubit _edit;

  @override
  void initState() {
    _edit = widget.operationEditCubit;
    super.initState();
  }

  @override
  void dispose() {
    _edit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OperationEditCubit, OperationEditState>(
        bloc: _edit,
        builder: (context, state) {
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
                        controller: _edit.title,
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
                                _edit.title.clear();
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
                        controller: _edit.money,
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
                              _edit.currencySymbol,
                              style: textStyle.apply(color: Colors.black87),
                            ),
                          ),
                          suffix: InkWell(
                            child: Icon(Icons.clear, color: Colors.black45),
                            onTap: () {
                              _edit.money.clear();
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
                        controller: _edit.actualMoney,
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
                              _edit.currencySymbol,
                              style: textStyle.apply(color: Colors.black87),
                            ),
                          ),
                          suffix: InkWell(
                            child: Icon(Icons.clear, color: Colors.black45),
                            onTap: () {
                              _edit.actualMoney.clear();
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
                    child:
                        Text(DateFormat.yMMMMd().format(_edit.operation.date)),
                    onPressed: () async {
                      await showDatePicker(
                        context: context,
                        initialDate: _edit.operation.date,
                        firstDate:
                            DateTime.now().subtract(Duration(days: 3650)),
                        lastDate: DateTime.now().add(Duration(days: 3650)),
                      ).then((value) {
                        if (value != null) {
                          _edit.setOperationExpectedDate(value);
                        }
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
                          Navigator.of(context).pop(_edit.operation);
                        },
                      ),
                    ],
                  ),
                  if (_edit.initial != null)
                    OutlinedButton.icon(
                      icon: Icon(Icons.remove),
                      label: Text("Удалить"),
                      onPressed: () async {
                        if (_edit.initial != null) {
                          context
                              .read<BudgetPredictionCubit>()
                              .deleteOperation(_edit.initial!);
                        }
                        Navigator.pop(context);
                      },
                    )
                ],
              ),
            )),
          );
        },
      ),
    );
  }
}
