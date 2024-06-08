// import 'package:moniplan_core/moniplan_core.dart';
//
// class PaymentPlannerRepoOB implements IPaymentPlannerRepo {
//   final Store store;
//
//   const PaymentPlannerRepoOB({
//     required this.store,
//   });
//
//   Box<PaymentPlannerDaoOB> get _plannerBox => store.box<PaymentPlannerDaoOB>();
//
//   static const _plannerMapper = PlannerMapperOB();
//
//   @override
//   Future<List<PaymentPlanner>> getPlanners() async {
//     final dao = await _plannerBox.getAllAsync();
//
//     final result = dao.map(_plannerMapper.toDomain).toList();
//     return result;
//   }
//
//   @override
//   Future<PaymentPlanner?> getLastPlanner() async {
//     final dao = (await _plannerBox.getAllAsync()).lastOrNull;
//
//     if (dao != null) {
//       return _plannerMapper.toDomain(dao);
//     }
//     return null;
//   }
//
//   @override
//   Future<PaymentPlanner?> getPlannerById(String id) async {
//     final dao = _plannerBox
//         .query(
//           PaymentPlannerDaoOB_.plannerId.equals(id),
//         )
//         .build()
//         .findUnique();
//
//     if (dao != null) {
//       final planner = _plannerMapper.toDomain(dao);
//       return planner;
//     }
//     return null;
//   }
// }
