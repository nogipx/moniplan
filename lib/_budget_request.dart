// ignore_for_file: implementation_imports

import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/features/payment_reference/repo/mock/_details.dart';

final currentRequest = PaymentPlanner(
  id: const Uuid().v4(),
  dateStart: DateTime(2024, 6, 1),
  dateEnd: DateTime(2024, 7, 0),
  initialBudget: 0,
  isDraft: true,
  payments: [
    '16.06'.p.info(Details.ipotekaLower).repeatMonth.build(),
    '21.06'.p.info(Details.ipotekaGreater).repeatMonth.build(),
    '06.09'.p.info(Details.refinanceCredit).repeatMonth.start('05.09'.date).build(),
    '14.06'.p.info(Details.creditCardTinkoff).repeatMonth.build(),
    '24.06'.p.info(Details.creditCardAlfa).repeatMonth.build(),
    '09.06'.p.info(Details.splitGooglePixelForce).disabled.build(),
    '09.06'.p.info(Details.creditTashkent).build(),
    '18.07'.p.info(Details.creditCar).repeatMonth.start('17.07'.date).build(),
    '09.06'.p.info(Details.kubishkaFullfill).build(),
    '07.06'.p.info(Details.salaryBristol).repeatMonth.build(),
    '05.06'.p.info(Details.salaryUzumHalf).repeatMonth.build(),
    '20.06'.p.info(Details.salaryUzumHalf).repeatMonth.build(),
    '15.06'.p.info(Details.salaryCopix).repeatMonth.build(),
    '21.06'.p.info(Details.rentHomeSuvorova).repeatMonth.build(),
    '10.06'.p.info(Details.communalBelichenko).repeatMonth.build(),
    '10.06'.p.info(Details.communalGondarya).repeatMonth.build(),
    '10.06'.p.info(Details.communalSuvorova).repeatMonth.build(),
    '15.06'.p.info(Details.catsSummary).repeatMonth.build(),
    '10.06'.p.info(Details.internet).repeatMonth.build(),
    '08.06'.p.info(Details.daryaLifeMonth).repeatMonth.build(),
    '08.06'.p.info(Details.natashaLifeMonth).repeatMonth.build(),
  ],
);
