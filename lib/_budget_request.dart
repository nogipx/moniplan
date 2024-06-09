// ignore_for_file: implementation_imports

import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/features/payment_reference/repo/mock/_details.dart';

final currentRequest = PaymentPlanner(
  id: const Uuid().v4(),
  dateStart: '08.06'.date,
  dateEnd: '00.08'.date,
  initialBudget: 185000,
  isDraft: true,
  payments: [
    /// Одноразовые
    ///
    '16.06'.p.info(D.splitGooglePixelForce).build(),
    '16.06'.p.info(D.creditTashkent).build(),
    '16.06'.p.info(D.kubishkaFullfill).build(),
    '16.06'.p.info(D.hairCorrection).build(),
    '16.06'.p.info(D.implanon).build(),
    '16.06'.p.info(D.cosmetic).build(),
    '16.06'.p.info(D.gym).build(),

    /// Регулярные зп
    ///
    '15.06'.p.info(D.salaryCopix).repeatMonth.start('14.06'.date).build(),
    '20.06'.p.info(D.salaryUzumHalf).repeatMonth.start('19.06'.date).build(),
    '05.07'.p.info(D.salaryUzumHalf).repeatMonth.start('04.07'.date).build(),
    '07.07'.p.info(D.salaryBristol).repeatMonth.start('06.07'.date).build(),

    /// Нерегулярные зп
    ///
    '05.07'.p.info(D.salaryUzumHalf.copyWith(money: 50000 + 250000)).build(),

    /// Кредиты
    ///
    '18.07'.p.info(D.creditCar).start('17.07'.date).repeatMonth.build(),
    '06.09'.p.info(D.refinanceCredit).start('05.09'.date).repeatMonth.build(),
    '16.06'.p.info(D.ipotekaLower).repeatMonth.build(),
    '21.06'.p.info(D.ipotekaGreater).repeatMonth.build(),

    /// Регулярные платежи
    ///
    '10.06'.p.info(D.communalBelichenko).repeatMonth.build(),
    '10.06'.p.info(D.communalGondarya).repeatMonth.build(),
    '10.06'.p.info(D.communalSuvorova).repeatMonth.build(),
    '14.06'.p.info(D.creditCardTinkoff).repeatMonth.build(),
    '10.06'.p.info(D.internet).repeatMonth.build(),
    '15.06'.p.info(D.catsSummary).repeatMonth.build(),
    '24.06'.p.info(D.creditCardAlfa).repeatMonth.build(),

    /// Регулярные переводы
    ///
    '21.06'.p.info(D.rentHomeSuvorova).repeatMonth.build(),
    '08.07'.p.info(D.daryaLifeMonth).repeatMonth.start('07.07'.date).build(),
    '08.07'.p.info(D.natashaLifeMonth).repeatMonth.start('07.07'.date).build(),
  ],
);
