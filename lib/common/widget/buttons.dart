import 'package:flutter/material.dart';
import 'package:moniplan/app/theme.dart';

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    Key? key,
    required this.text,
    this.onTap,
    this.height = 56,
    this.isLoading = false,
  }) : super(key: key);

  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final textColor = onTap == null ? AppTheme.inactiveTextColor : Colors.white;

    return Material(
      color: onTap == null
          ? AppTheme.inactiveBackgroundColor
          : AppTheme.lightBlueColor,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        // splashFactory: NoSplash.splashFactory,
        onTap: onTap,
        child: Container(
          height: height,
          alignment: Alignment.center,
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isLoading;
  final double height;

  const SecondaryActionButton({
    Key? key,
    required this.text,
    this.height = 56,
    this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final textColor = onTap == null
        ? AppTheme.inactiveTextColor
        : isDestructive
            ? closeColor
            : AppTheme.lightBlueColor;

    return Material(
      borderRadius: borderRadius,
      color: AppTheme.inactiveBackgroundColor,
      child: InkWell(
        onTap: onTap,
        // splashFactory: NoSplash.splashFactory,
        borderRadius: borderRadius,
        child: Container(
          height: height,
          alignment: Alignment.center,
          child: Text(
            text,
            style:
                Theme.of(context).textTheme.bodyText1?.apply(color: textColor),
          ),
        ),
      ),
    );
  }
}

class TextActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isDestructive;

  const TextActionButton({
    Key? key,
    required this.text,
    this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(4);
    final textColor = onTap == null
        ? inactiveTextColor
        : isDestructive
            ? closeColor
            : lightBlueColor;

    return Material(
      borderRadius: borderRadius,
      color: secondaryColor,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        borderRadius: borderRadius,
        child: Container(
          height: 40,
          constraints: BoxConstraints.tightFor(),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          alignment: Alignment.center,
          child: Text(
            text,
            style:
                Theme.of(context).textTheme.bodyText1?.apply(color: textColor),
          ),
        ),
      ),
    );
  }
}
