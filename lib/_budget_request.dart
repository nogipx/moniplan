// ignore_for_file: implementation_imports

import 'package:moniplan_core/moniplan_core.dart';
import 'package:moniplan_core/src/features/payment_reference/repo/mock/_details.dart';

final currentRequest = PaymentPlanner(
  id: const Uuid().v4(),
  dateStart: '08.06'.date,
  dateEnd: '00.12'.date,
  initialBudget: 165000,
  isDraft: true,
  payments: [
    /// Регулярные зп
    ///
    '15.06'.p.info(D.salaryCopix).repeatMonth.start('15.07'.date).build(),
    '07.07'.p.info(D.salaryBristol).repeatMonth.start('07.07'.date).build(),
    '20.06'
        .p
        .info(D.salaryUzumHalf.copyWith(money: 115000))
        .repeatMonth
        .start('20.07'.date)
        .end('05.13'.date)
        .build(),
    '05.07'
        .p
        .info(D.salaryUzumHalf.copyWith(money: 115000))
        .repeatMonth
        .start('05.07'.date)
        .end('05.13'.date)
        .build(),

    /// Нерегулярные зп
    ///
    '05.07'.p.info(D.salaryUzumHalf.copyWith(money: 250000)).build(), // мейби придет больше

    /// Кредиты
    ///
    '18.07'.p.info(D.creditCar).start('18.07'.date).repeatMonth.build(),
    '06.09'.p.info(D.refinanceCredit).start('06.09'.date).repeatMonth.build(),
    '16.06'.p.info(D.ipotekaLower).start('16.07'.date).repeatMonth.build(),
    '21.06'.p.info(D.ipotekaGreater.copyWith(money: 41000)).start('21.07'.date).repeatMonth.build(),
    '14.06'.p.info(D.creditCardTinkoff).start('14.07'.date).end('21.06'.date).repeatMonth.build(),
    // '24.06'.p.info(D.creditCardAlfa).repeatMonth.end('08.07'.date).build(),

    /// Регулярные платежи
    ///
    '10.06'.p.start('10.7'.date).info(D.communalBelichenko).repeatMonth.build(),
    '10.06'.p.start('10.7'.date).info(D.communalGondarya).repeatMonth.build(),
    '10.06'.p.start('10.7'.date).info(D.communalSuvorova).repeatMonth.build(),
    '10.06'.p.start('10.7'.date).info(D.internet).repeatMonth.build(),
    '10.06'.p.start('10.7'.date).info(D.catsSummary).repeatMonth.build(),
    '26.07'.p.info(D.splitGooglePixel).build(),

    /// Регулярные переводы
    ///
    '21.06'.p.info(D.rentHomeSuvorova).repeatMonth.start('21.07'.date).build(),
    '08.07'
        .p
        .info(D.daryaLifeMonth.copyWith(money: 100000))
        .repeatMonth
        .start('08.07'.date)
        .build(),
    '08.07'.p.info(D.natashaLifeMonth.copyWith(money: 20000)).build(),

    /// Одноразовые
    ///
    '08.07'.p.info(D.implanon).build(),
    '08.07'.p.info(D.arsenyCarCompens).build(),
    '03.07'.p.info(D.hairCorrection).build(),
    '16.07'.p.info(D.cosmetic).build(),
    // '08.07'.p.info(D.gym).build(),
    '08.10'.p.info(D.closeCreditCardAlfa).build(),
    '16.07'.p.info(D.closeCreditCardTinkoff).build(),
    // '08.08'.p.info(D.macbookUpdate).build(),

    /// Done .06 Июнь
    ///
    '09.06'.p.done.info(D.creditCardTinkoff).build(),
    '10.06'.p.done.info(D.communalBelichenko).build(),
    '10.06'.p.done.info(D.communalGondarya).build(),
    '10.06'.p.done.info(D.communalSuvorova).build(),
    '10.06'.p.done.info(D.internet).build(),
    '10.06'.p.done.info(D.catsSummary).build(),
    '16.06'.p.done.input('Влил из сверх', 3000).build(),
    '16.06'.p.done.info(D.ipotekaLower).build(),
    '16.06'.p.done.info(D.ipotekaGreater).build(),
    '13.06'.p.done.info(D.carInvestment.copyWith(money: 20000)).build(),
    '16.06'.p.done.info(D.kubishkaFullfill).build(),
    '20.06'.p.done.info(D.salaryUzumHalf).build(),
    '21.06'.p.done.info(D.rentHomeSuvorova).build(),
    '21.06'.p.done.info(D.salaryCopix.copyWith(money: 220000, tax: 0)).build(),
    '29.06'.p.done.info(D.closeCreditCardMts).build(),
    '29.06'.p.done.info(D.splitGooglePixel).build(),
    '29.06'.p.done.info(D.kubishkaFullfill.copyWith(money: 32000)).build(),
    '29.06'.p.done.info(D.creditCardTinkoff).build(),
    '29.06'.p.done.info(D.creditTashkent).build(),

    // '20.06'.p.info(D.carInvestment.copyWith(money: 25000)).build(),
  ],
);
