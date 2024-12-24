import 'package:flutter/material.dart';
import 'package:moniplan/features/_common/_index.dart';
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
  final ValueNotifier<Set<PaymentDetails>> _selectedPayments = ValueNotifier({});

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

  void _selectPayment(PaymentDetails payment) {
    final data = Set.of(_selectedPayments.value)..add(payment);
    _selectedPayments.value = data;
  }

  void _deselectPayment(PaymentDetails payment) {
    final data = Set.of(_selectedPayments.value)..remove(payment);
    _selectedPayments.value = data;
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
              currency: CurrencyDataCommon.rub,
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
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
              child: AnimatedBuilder(
                animation: Listenable.merge([_paymentsToShow, _selectedPayments]),
                builder: (context, child) {
                  final payments = _paymentsToShow.value;
                  final selected = _selectedPayments.value;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      final isSelected = selected.contains(payment);

                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            _deselectPayment(payment);
                          } else {
                            _selectPayment(payment);
                          }
                        },
                        child: Card(
                          elevation: isSelected ? 3 : 1,
                          child: Grayscale(
                            grayscale: isSelected,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(payment.name),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          MoneyColoredWidget(
                                            value: payment.normalizedMoney,
                                            currency: CurrencyDataCommon.rub,
                                            showPlusSign: true,
                                          ),
                                          if (payment.tax > 0)
                                            Text(
                                              'Налог ${(payment.tax * 100).toInt()}%',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            )
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (payment.note.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Text(
                                        payment.note,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    payment.tags.map((e) => '#$e').join('  '),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
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
