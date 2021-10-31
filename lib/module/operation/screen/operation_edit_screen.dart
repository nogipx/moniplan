import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moniplan/common/export.dart';
import 'package:moniplan/common/widget/inputs.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/module/operation/cubit/operation_edit_cubit.dart';
import 'package:moniplan/sdk/domain.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<OperationEditCubit, OperationEditState>(
            bloc: _edit,
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppTextField(
                      controller: _edit.title,
                      hintText: 'Название',
                      onClear: () => _edit.title.clear(),
                    ),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: _edit.expectedMoney,
                      onClear: () => _edit.expectedMoney.clear(),
                      currency: CommonCurrencies().rub,
                      hintText: 'Ожидаемая сумма',
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      inputFormatters: [moneyInputFormatter],
                    ),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: _edit.actualMoney,
                      onClear: () => _edit.actualMoney.clear(),
                      currency: CommonCurrencies().rub,
                      hintText: 'Фактическая сумма',
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      inputFormatters: [moneyInputFormatter],
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      child: Text(
                          DateFormat.yMMMMd().format(_edit.operation.date)),
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
                    SizedBox(height: 8),
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
                            context
                                .read<BudgetPredictionCubit>()
                                .saveOperation(_edit.operation);
                            Navigator.of(context).pop(_edit.operation);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
