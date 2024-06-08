import 'package:flutter/material.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class PaymentsReferenceScreen extends StatefulWidget {
  const PaymentsReferenceScreen({super.key});

  @override
  State<PaymentsReferenceScreen> createState() => _PaymentsReferenceScreenState();
}

class _PaymentsReferenceScreenState extends State<PaymentsReferenceScreen> {
  late final IPaymentsReferenceRepo _paymentsReferenceRepo;

  List<String> _availableTags = [];
  List<PaymentDetails> _payments = [];

  final ValueNotifier<num> _sumOfData = ValueNotifier(0.0);
  final ValueNotifier<String> _selectedTag = ValueNotifier('');
  final ValueNotifier<List<PaymentDetails>> _paymentsToShow = ValueNotifier([]);

  @override
  void initState() {
    super.initState();

    _paymentsReferenceRepo = MockPaymentsReferenceRepo();
  }

  @override
  void dispose() {
    super.dispose();

    _sumOfData.dispose();
    _selectedTag.dispose();
    _paymentsToShow.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _paymentsReferenceRepo.getAvailableTags().then((value) {
      setState(() {
        _availableTags = value.toList();
      });
    });

    _paymentsReferenceRepo.getPaymentsDetailsReference().then((value) {
      setState(() {
        _payments = value;
      });
      _paymentsToShow.value = value;
      _sumOfData.value = _computeSum(value);
    });
  }

  num _computeSum(List<PaymentDetails> data) {
    final result = data.map((e) => e.normalizedMoney).fold(0.0, (a, b) => a + b);
    return result;
  }

  void _selectTag(String tag) {
    _selectedTag.value = tag;
    _paymentsToShow.value = _payments.where((e) => e.tags.contains(tag)).toList();
    _sumOfData.value = _computeSum(_paymentsToShow.value);
  }

  void _clearTagSelection() {
    _selectedTag.value = '';
    _paymentsToShow.value = _payments;
    _sumOfData.value = _computeSum(_paymentsToShow.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: _sumOfData,
          builder: (context, sum, _) {
            return MoneyColoredWidget(
              value: sum,
              currency: AppCurrencies.ru,
              showPlusSign: true,
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: _selectedTag,
              builder: (context, selectedTag, _) {
                return SizedBox(
                  height: 60,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableTags.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tag = _availableTags[index];
                      final isSelected = _selectedTag.value == tag;

                      return ActionChip(
                        label: Text(
                          tag,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? MoniplanColors.white
                                    : MoniplanColors.primaryTextColor,
                              ),
                        ),
                        backgroundColor: isSelected
                            ? MoniplanColors.blueColor
                            : MoniplanColors.inactiveBackgroundColor,
                        onPressed: () {
                          if (isSelected) {
                            _clearTagSelection();
                          } else {
                            _selectTag(tag);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _paymentsToShow,
                builder: (context, payments, _) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(payment.name),
                                  const SizedBox(width: 8),
                                  MoneyColoredWidget(
                                    value: payment.normalizedMoney,
                                    currency: AppCurrencies.ru,
                                    showPlusSign: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                payment.tags.map((e) => '#$e').join('  '),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: MoniplanColors.secondaryTextColor),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
