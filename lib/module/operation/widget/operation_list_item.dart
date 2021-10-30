import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moniplan/common/export.dart';
import 'package:moniplan/module/operation/cubit/budget_prediction_cubit.dart';
import 'package:moniplan/module/operation/widget/operation_preview.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/common/util/export.dart';
import 'package:moniplan/module/operation/export.dart';

class OperationWidget extends StatelessWidget {
  final Operation operation;
  final VoidCallback? onPressed;
  final VoidCallback? onToggleEnable;

  const OperationWidget({
    Key? key,
    required this.operation,
    this.onPressed,
    this.onToggleEnable,
  }) : super(key: key);

  Widget _buildToggleEnable() {
    return IconButton(
      constraints: BoxConstraints.tightFor(width: 26, height: 26),
      padding: const EdgeInsets.all(0),
      splashRadius: 24,
      icon: Icon(
        operation.actualValue == null
            ? operation.enabled
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined
            : Icons.check,
        color: operation.enabled
            ? AppTheme.lightBlueColor
            : AppTheme.disabledColor,
        size: 26,
      ),
      onPressed: operation.actualValue == null ? onToggleEnable : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Grayscale(
      grayscale: !operation.enabled,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: _buildToggleEnable(),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    operation.reason,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyText1?.apply(
                          color:
                              operation.enabled ? null : AppTheme.disabledColor,
                        ),
                  ),
                ),
                SizedBox(width: 4),
                CurrencyColorWidget(
                  value: operation.actualValue ?? operation.expectedValue,
                  overrideColor:
                      !operation.enabled ? AppTheme.disabledColor : null,
                  currency: CommonCurrencies().rub,
                  textStyle: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<Operation?> showPreviewSheet({
    required BuildContext context,
    required Operation initialData,
  }) async {
    final result = await showCupertinoModalBottomSheet<Operation?>(
      barrierColor: Colors.black38,
      context: context,
      previousRouteAnimationCurve: Curves.easeInCubic,
      duration: Duration(milliseconds: 300),
      builder: (context) {
        return BlocBuilder<BudgetPredictionCubit, BudgetPredictionState>(
          builder: (context, state) {
            return OperationPreview(
              operation: context
                      .read<BudgetPredictionCubit>()
                      .operationsByDay[initialData.date]
                      ?.singleWhere(
                        (e) => e.id == initialData.id,
                        orElse: () => initialData,
                      ) ??
                  initialData,
            );
          },
        );
      },
    );
    return result;
  }

  static Future<Operation?> showEdit({
    required BuildContext context,
    Operation? initialData,
  }) async {
    return Navigator.of(context).push(
      MaterialPageRoute<Operation>(
        builder: (BuildContext context) {
          return SizedBox();
        },
      ),
    ).then((value) {
      if (value != null) {
        context.read<BudgetPredictionCubit>().saveOperation(value);
      }
      return value;
    });
  }
}
