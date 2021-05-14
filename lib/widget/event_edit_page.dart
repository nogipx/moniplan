// import 'package:flutter/material.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:moniplan/bloc/budget_prediction_bloc.dart';
// import 'package:moniplan/sdk/domain.dart';
// import "package:flutter_bloc/flutter_bloc.dart";
// import 'package:dartx/dartx.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:intl/intl.dart';
// import 'package:moniplan/widget/budget/operation_edit_widget.dart';
// import 'package:moniplan/widget/budget/operation_widget.dart';

// class OperationEditPage extends StatefulWidget {
//   final Operation? initialData;
//   final void Function(BudgetPrediction event)? onSaved;

//   const OperationEditPage({Key? key, required this.initialData, this.onSaved})
//       : super(key: key);

//   @override
//   _OperationEditPageState createState() => _OperationEditPageState();

//   static Future<Operation?> showEditModal({
//     required BuildContext context,
//     Operation? initialData,
//   }) async {
//     return await showMaterialModalBottomSheet<Operation>(
//       duration: Duration(milliseconds: 250),
//       expand: true,
//       context: context,
//       enableDrag: false,
//       builder: (context) {
//         return OperationEditPage(initialData: initialData);
//       },
//     );
//   }
// }

// class _OperationEditPageState extends State<OperationEditPage> {
//   late Operation _data;
//   late final BudgetPredictionBloc _budgetPredictionBloc;
//   late final OperationService _operationService;

//   @override
//   void initState() {
//     final now = DateTime.now();
//     _budgetPredictionBloc = context.read<BudgetPredictionBloc>();
//     _operationService = context.read<OperationService>();

//     if (widget.initialData != null) {
//       _data = widget.initialData!.copyWith();
//     } else {
//       _data = Operation.outcome(date: now, value: 0, reason: '');
//     }
//     super.initState();
//   }

//   void _saveEvent() {
//     _operationService.save(_data);
//     _budgetPredictionBloc.compute();
//   }

//   void _deleteEvent() {
//     _operationService.delete(_data);
//     _budgetPredictionBloc.compute();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () {
//         return showDialog<bool>(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               content: Text("Save changes?"),
//               actions: [
//                 TextButton(
//                   child: Text("Discard"),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 TextButton(
//                   child: Text("Save"),
//                   onPressed: () {
//                     _saveEvent();
//                     _budgetPredictionBloc.compute();
//                     Navigator.of(context).pop(_data);
//                   },
//                 ),
//               ],
//             );
//           },
//         ).then((value) => value ?? true);
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           iconTheme: IconThemeData(color: Colors.black87),
//         ),
//         body: SafeArea(
//           child: ListView(
//             padding: EdgeInsets.all(16),
//             shrinkWrap: true,
//             children: [
//               TextButton(
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(_data.date.date.format()),
//                 ),
//                 onPressed: () async {
//                   await showDatePicker(
//                     context: context,
//                     initialDate: _data.date.date,
//                     firstDate: DateTime.now().subtract(Duration(days: 3650)),
//                     lastDate: DateTime.now().add(Duration(days: 3650)),
//                   ).then((value) {
//                     setState(() {
//                       _data = _data.copyWith(date: value?.date);
//                     });
//                   });
//                 },
//               ),
//               OperationEditDialog(
//                 operation: _data,
//               ),
//               OperationWidget(
//                 data: _data,
//               ),
//               ElevatedButton(
//                 child: Text("Save"),
//                 onPressed: () {
//                   _saveEvent();
//                   Navigator.of(context).pop(_data);
//                 },
//               ),
//               Offstage(
//                 offstage: widget.initialData == null,
//                 child: OutlinedButton(
//                   child: Text("Delete"),
//                   style: ButtonStyle(
//                     overlayColor:
//                         MaterialStateProperty.all(Colors.red.withOpacity(.12)),
//                     foregroundColor: MaterialStateProperty.all(Colors.red),
//                   ),
//                   onPressed: () {
//                     _deleteEvent();
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// extension DateTimeExtension on DateTime {
//   String format({String pattern = 'dd/MM/yyyy', String? locale}) {
//     if (locale != null && locale.isNotEmpty) {
//       initializeDateFormatting(locale);
//     }
//     return DateFormat(pattern, locale).format(this);
//   }
// }
