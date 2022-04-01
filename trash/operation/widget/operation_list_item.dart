import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moniplan/common/export.dart';
import 'package:moniplan/module/operation/export.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/app/theme.dart';

class OperationWidget extends StatelessWidget {
  const OperationWidget({
    Key? key,
    required this.operation,
    this.onPressed,
    this.onToggleEnable,
    this.textColor,
  }) : super(key: key);

  final Operation operation;
  final VoidCallback? onPressed;
  final VoidCallback? onToggleEnable;
  final Color? textColor;

  Widget _buildToggleEnable() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: operation.actualValue == null ? onToggleEnable : null,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 26,
          child: Icon(
            operation.actualValue == null
                ? operation.enabled
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank_outlined
                : Icons.check,
            color: operation.enabled
                ? AppTheme.lightBlueColor
                : AppTheme.disabledColor,
            size: operation.actualValue == null ? 26 : 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Grayscale(
      grayscale: !operation.enabled,
      child: InkWell(
        onTap: onPressed,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildToggleEnable(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    operation.reason,
                    maxLines: 5,
                    style: Theme.of(context).textTheme.bodyText1?.apply(
                          color: operation.enabled
                              ? textColor
                              : AppTheme.disabledColor,
                        ),
                  ),
                ),
              ),
              SizedBox(width: 4),
              MoneyColoredWidget(
                value: operation.actualValue ?? operation.expectedValue,
                overrideColor:
                    !operation.enabled ? AppTheme.disabledColor : null,
                currency: operation.currency,
                textStyle: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(width: 16)
            ],
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
      context: context,
      animationCurve: Curves.fastLinearToSlowEaseIn,
      duration: Duration(milliseconds: 250),
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
    final result = await showCupertinoModalBottomSheet<Operation?>(
      context: context,
      animationCurve: Curves.easeInOut,
      duration: Duration(milliseconds: 350),
      builder: (context) {
        return BaseBottomSheet(
          expand: true,
          child: OperationEditScreen(
            operationEditCubit: OperationEditCubit(
              initial: initialData,
            ),
          ),
        );
      },
    );
    return result;
  }
}
