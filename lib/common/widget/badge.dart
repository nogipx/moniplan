import 'package:flutter/material.dart';
import 'package:moniplan/app/theme.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({
    Key? key,
    required this.text,
    this.enabled = false,
    this.onTap,
    this.prefix,
    this.fontSize,
  }) : super(key: key);

  final String text;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget? prefix;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    return Material(
      color: AppTheme.inactiveBackgroundColor,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: enabled ? Border.all(color: AppTheme.lightBlueColor) : null,
            borderRadius: borderRadius,
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: prefix,
                ),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        fontSize: fontSize,
                        color: enabled ? AppTheme.blueColor : null,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
