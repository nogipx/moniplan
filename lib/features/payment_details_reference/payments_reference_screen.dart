import 'package:flutter/material.dart';
import 'package:moniplan/main.dart';
import 'package:moniplan_core/moniplan_core.dart';

class PaymentsReferenceScreen extends StatefulWidget {
  const PaymentsReferenceScreen({super.key});

  @override
  State<PaymentsReferenceScreen> createState() => _PaymentsReferenceScreenState();
}

class _PaymentsReferenceScreenState extends State<PaymentsReferenceScreen> {
  late final IPaymentsReferenceRepo _paymentsReferenceRepo;

  @override
  void initState() {
    super.initState();
    _paymentsReferenceRepo = PaymentsReferenceRepoDrift(db: db);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
