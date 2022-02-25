import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/common/export.dart';
import 'package:moniplan/common/widget/inputs.dart';
import 'package:moniplan/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/cubit/operation_edit_cubit.dart';
import 'package:moniplan/widget/edit_money.dart';
import 'package:provider/provider.dart';

class OperationEditScreen extends StatefulWidget {
  const OperationEditScreen({
    Key? key,
    required this.operationEditCubit,
  }) : super(key: key);

  final OperationEditCubit operationEditCubit;

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
    return SafeArea(
      child: BlocBuilder<OperationEditCubit, OperationEditState>(
        bloc: _edit,
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _edit.initial != null ? 'Редактирование' : 'Создание',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              const SizedBox(height: 24),
              _buildNameData(context),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Сумма',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: EditMoneyWidget(editCubit: _edit),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.bottomCenter,
                child: PrimaryActionButton(
                  text: 'Готово',
                  onTap: _edit.isValid
                      ? () {
                          if (_edit.isValid) {
                            context
                                .read<BudgetPredictionCubit>()
                                .saveOperation(_edit.operation);
                            Navigator.of(context).pop(_edit.operation);
                          }
                        }
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNameData(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Название и дата',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(height: 16),
              AppTextField(
                controller: _edit.title,
                hintText: 'Название',
                autofocus: _edit.title.text.isEmpty,
                onClear: () => _edit.title.clear(),
              ),
              SizedBox(height: 4),
              TextButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateFormatYear.format(_edit.operation.date),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.apply(color: AppTheme.lightBlueColor),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppTheme.inactiveTextColor,
                    )
                  ],
                ),
                onPressed: () async {
                  await showDatePicker(
                    context: context,
                    initialDate: _edit.operation.date,
                    firstDate: DateTime.now().subtract(Duration(days: 3650)),
                    lastDate: DateTime.now().add(Duration(days: 3650)),
                  ).then((value) {
                    if (value != null) {
                      _edit.setOperationExpectedDate(value);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
