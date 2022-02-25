import 'package:flutter/material.dart';
import 'package:moniplan/common/export.dart';
import 'package:moniplan/cubit/operation_edit_cubit.dart';

enum EditMoneyTab { Expected, Actual }

class EditMoneyWidget extends StatefulWidget {
  const EditMoneyWidget({
    Key? key,
    required this.editCubit,
    this.initialTab,
    this.autofocus = false,
  }) : super(key: key);

  final OperationEditCubit editCubit;
  final EditMoneyTab? initialTab;
  final bool autofocus;

  @override
  _EditMoneyWidgetState createState() => _EditMoneyWidgetState();
}

class _EditMoneyWidgetState extends State<EditMoneyWidget> {
  late final ValueNotifier<EditMoneyTab> _tab;

  @override
  void initState() {
    const t = "";
    _tab = ValueNotifier(widget.initialTab ??
        (widget.editCubit.operation.actualValue != null
            ? EditMoneyTab.Actual
            : EditMoneyTab.Expected));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EditMoneyTab>(
      valueListenable: _tab,
      builder: (context, tab, _) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: BadgeWidget(
                      enabled: tab == EditMoneyTab.Expected,
                      text: 'Ожидаемая',
                      onTap: () => _tab.value = EditMoneyTab.Expected,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: BadgeWidget(
                      enabled: tab == EditMoneyTab.Actual,
                      text: 'Фактическая',
                      onTap: () => _tab.value = EditMoneyTab.Actual,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (tab == EditMoneyTab.Expected)
                AppTextField(
                  controller: widget.editCubit.expectedMoney,
                  onClear: () => widget.editCubit.expectedMoney.clear(),
                  currency: widget.editCubit.operation.currency,
                  hintText: 'Ожидаемая сумма',
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  inputFormatters: [moneyInputFormatter],
                ),
              if (tab == EditMoneyTab.Actual)
                AppTextField(
                  controller: widget.editCubit.actualMoney,
                  onClear: () => widget.editCubit.actualMoney.clear(),
                  currency: widget.editCubit.operation.currency,
                  hintText: 'Фактическая сумма',
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  inputFormatters: [moneyInputFormatter],
                ),
            ],
          ),
        );
      },
    );
  }
}
