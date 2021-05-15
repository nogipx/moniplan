import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/widget/budget/budget_summary.dart';
import 'package:moniplan/widget/budget/operation_edit.dart';

class OperationWidget extends StatelessWidget {
  final Operation data;
  final void Function()? onPressed;

  const OperationWidget({Key? key, required this.data, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                data.reason.isNotEmpty ? data.reason : "No reason",
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(color: Colors.black87),
              ),
            ),
            SizedBox(width: 16),
            CurrencyColorWidget(
              value: data.result,
              textStyle: Theme.of(context).textTheme.subtitle1,
              currency: data.currency,
            )
          ],
        ),
      ),
    );
  }

  static Future<Operation?> showEdit({
    required BuildContext context,
    Operation? initialData,
  }) async {
    final result = await showBarModalBottomSheet<Operation?>(
      barrierColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.grey,
      expand: true,
      duration: Duration(milliseconds: 250),
      enableDrag: true,
      context: context,
      builder: (context) {
        return OperationEditWidget(initialData: initialData);
      },
    );
    return result;
  }
}
