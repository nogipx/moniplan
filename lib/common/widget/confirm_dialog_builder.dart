import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moniplan/common/widget/buttons.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    this.title,
    this.contentText,
    this.cancelText,
    this.approveText,
    this.child,
    this.approveValidator,
  });

  final String? title;
  final Widget? child;
  final String? contentText;
  final String? cancelText;
  final String? approveText;
  final bool Function()? approveValidator;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              if (title != null) const SizedBox(height: 16),
              if (child == null)
                Text(
                  contentText ?? 'Вы уверены?',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              if (child != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: child,
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: approveText != null
                        ? SecondaryActionButton(
                            height: 40,
                            onTap: () => Navigator.pop(context, false),
                            text: cancelText ?? 'Отмена',
                          )
                        : PrimaryActionButton(
                            height: 40,
                            onTap: () => Navigator.pop(context, false),
                            text: cancelText ?? 'Понятно',
                          ),
                  ),
                  if (approveText != null)
                    const SizedBox(
                      width: 20,
                    ),
                  if (approveText != null)
                    Expanded(
                      child: PrimaryActionButton(
                        height: 40,
                        onTap: (approveValidator?.call() ?? true)
                            ? () => Navigator.pop(context, true)
                            : null,
                        text: approveText!,
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
