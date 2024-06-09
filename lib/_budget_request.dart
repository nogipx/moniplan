// ignore_for_file: implementation_imports

import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/features/payment_reference/repo/mock/_details.dart';

final currentRequest = PaymentPlanner(
  id: const Uuid().v4(),
  dateStart: '08.06'.date,
  dateEnd: '00.8'.date,
  initialBudget: 165000,
  isDraft: true,
  payments: [
    /// Одноразовые
    ///
    '16.06'.p.info(D.splitGooglePixelForce).build(),
    '16.06'.p.info(D.kubishkaFullfill).build(),
    '16.06'.p.info(D.hairCorrection).build(),
    '16.06'.p.info(D.implanon).build(),
    '16.06'.p.info(D.cosmetic).build(),
    '21.06'.p.info(D.closeCreditCardTinkoff).build(),
    '06.07'.p.info(D.creditTashkent).build(),
    '08.07'.p.info(D.gym).build(),
    '08.07'.p.info(D.closeCreditCardAlfa).build(),

    /// Регулярные зп
    ///
    '15.06'.p.info(D.salaryCopix).repeatMonth.start('15.06'.date).build(),
    '20.06'.p.info(D.salaryUzumHalf).repeatMonth.start('20.06'.date).build(),
    '05.07'.p.info(D.salaryUzumHalf).repeatMonth.start('05.07'.date).build(),
    '07.07'.p.info(D.salaryBristol).repeatMonth.start('07.07'.date).build(),

    /// Нерегулярные зп
    ///
    '05.07'.p.info(D.salaryUzumHalf.copyWith(money: 250000)).build(), // мейби придет больше

    /// Кредиты
    ///
    '18.07'.p.info(D.creditCar).start('18.07'.date).repeatMonth.build(),
    '06.09'.p.info(D.refinanceCredit).start('06.09'.date).repeatMonth.build(),
    '16.06'.p.info(D.ipotekaLower).repeatMonth.build(),
    '21.06'.p.info(D.ipotekaGreater).repeatMonth.build(),
    '14.06'.p.info(D.creditCardTinkoff).repeatMonth.start('14.07'.date).end('21.06'.date).build(),
    '24.06'.p.info(D.creditCardAlfa).repeatMonth.end('08.07'.date).build(),

    /// Регулярные платежи
    ///
    '10.06'.p.info(D.communalBelichenko).repeatMonth.build(),
    '10.06'.p.info(D.communalGondarya).repeatMonth.build(),
    '10.06'.p.info(D.communalSuvorova).repeatMonth.build(),
    '10.06'.p.info(D.internet).repeatMonth.build(),
    '15.06'.p.info(D.catsSummary).repeatMonth.build(),

    /// Регулярные переводы
    ///
    '21.06'.p.info(D.rentHomeSuvorova).repeatMonth.build(),
    '08.07'.p.info(D.daryaLifeMonth).repeatMonth.start('08.07'.date).build(),
    '08.07'.p.info(D.natashaLifeMonth).repeatMonth.start('08.07'.date).build(),

    /// Done .06 Июнь
    ///
    '09.06'.p.info(D.creditCardTinkoff).build(),
  ],
);
