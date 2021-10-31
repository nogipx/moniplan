import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moniplan/app/theme.dart';
import 'package:moniplan/sdk/domain/currency.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    required this.controller,
    this.onClear,
    this.decoration,
    this.currency,
    this.keyboardType,
    this.hintText,
    this.inputFormatters,
  }) : super(key: key);

  final TextEditingController controller;
  final VoidCallback? onClear;
  final InputDecoration? decoration;
  final Currency? currency;
  final TextInputType? keyboardType;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyText1!;
    return Material(
      color: AppTheme.inactiveBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (currency != null)
              Text(
                currency!.symbol,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(color: AppTheme.blueColor),
              ),
            if (currency != null) SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                style: textStyle,
                maxLines: 3,
                minLines: 1,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                decoration: InputDecoration(
                  hintStyle: textStyle.apply(color: AppTheme.inactiveTextColor),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: hintText,
                  contentPadding: const EdgeInsets.all(0),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: controller.text.isNotEmpty
                  ? IconButton(
                      constraints: BoxConstraints.tightForFinite(),
                      onPressed: onClear,
                      padding: const EdgeInsets.all(0),
                      icon: Icon(
                        Icons.clear,
                        color: Colors.black45,
                        size: 20,
                      ),
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
