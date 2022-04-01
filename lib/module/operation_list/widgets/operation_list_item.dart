import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moniplan/common/export.dart';
import 'package:moniplan/module/operation_list/export.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/app/app_theme.dart';

class OperationWidget extends StatelessWidget {
  final Operation operation;
  final VoidCallback? onPressed;
  final VoidCallback? onToggleEnable;
  final Color? textColor;

  const OperationWidget({
    required this.operation,
    this.onPressed,
    this.onToggleEnable,
    this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Grayscale(
      grayscale: !operation.enabled,
      child: InkWell(
        onTap: onPressed,
        child: IntrinsicHeight(
          child: Row(
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
              const SizedBox(width: 4),
              MoneyColoredWidget(
                value: operation.actualValue ?? operation.expectedValue,
                overrideColor:
                    !operation.enabled ? AppTheme.disabledColor : null,
                currency: operation.currency,
                textStyle: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  static Future<Operation?> showPreviewSheet({
    required BuildContext context,
    required Operation initialData,
    required OperationsListScreenWM operationsListScreenWM,
  }) async {
    final result = await showCupertinoModalBottomSheet<Operation?>(
      context: context,
      animationCurve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 250),
      builder: (context) {
        return EntityStateNotifierBuilder(
          listenableEntityState: operationsListScreenWM.result,
          builder: (context, data) {
            // return OperationPreview(
            //   operation: data.operationsByDay[initialData.date]?.singleWhere(
            //         (e) => e.id == initialData.id,
            //         orElse: () => initialData,
            //       ) ??
            //       initialData,
            // );
            return const SizedBox();
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
      duration: const Duration(milliseconds: 350),
      builder: (context) {
        return BaseBottomSheet(
          expand: true,
          child: OperationEditScreen(
            operationEditCubit: OperationEditCubit(
              initial: initialData,
            ),
          ),
        );
        return const SizedBox();
      },
    );
    return result;
  }

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
}
