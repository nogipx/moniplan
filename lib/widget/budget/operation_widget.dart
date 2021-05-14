import 'package:flutter/material.dart';
import 'package:moniplan/sdk/domain.dart';
import 'package:moniplan/widget/budget/budget_summary.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_circle,
              color: Colors.black38,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  data.reason.isNotEmpty ? data.reason : "No reason",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(color: Colors.black87),
                ),
              ),
            ),
            CurrencyColorWidget(
              value: data.result,
              textStyle: Theme.of(context).textTheme.subtitle1,
            )
          ],
        ),
      ),
    );
  }
}
