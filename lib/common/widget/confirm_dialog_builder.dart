import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moniplan/common/widget/buttons.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    this.title,
    this.content,
    this.cancelText,
    this.approveText,
  });

  final String? title;
  final String? content;
  final String? cancelText;
  final String? approveText;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              if (title != null)
                const SizedBox(
                  height: 16,
                ),
              Text(
                content ?? 'Вы уверены?',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
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
                        onTap: () => Navigator.pop(context, true),
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
