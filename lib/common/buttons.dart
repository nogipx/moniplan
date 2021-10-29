import 'package:flutter/material.dart';
import 'package:moniplan/app/theme.dart';

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;

  const PrimaryActionButton({
    Key? key,
    required this.text,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    return Material(
      color: onTap != null
          ? AppTheme.inactiveBackgroundColor
          : AppTheme.lightBlueColor,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        // splashFactory: NoSplash.splashFactory,
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyText1?.apply(
                  color: onTap == null ? inactiveTextColor : null,
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

  const SecondaryActionButton({
    Key? key,
    required this.text,
    this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final textColor = onTap == null
        ? AppTheme.inactiveTextColor
        : isDestructive
            ? closeColor
            : AppTheme.lightBlueColor;

    return Material(
      borderRadius: borderRadius,
      color: secondaryColor,
      child: InkWell(
        onTap: onTap,
        // splashFactory: NoSplash.splashFactory,
        borderRadius: borderRadius,
        child: Container(
          height: 56,
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

class TinkoffIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  const TinkoffIconButton({
    Key? key,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffF6F7F8),
      ),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: onTap,
        child: SizedBox(
          height: 18,
          width: 18,
          child: icon,
        ),
      ),
    );
  }
}
