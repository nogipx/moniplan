import 'package:flutter_bloc/flutter_bloc.dart';

part 'payment_edit_event.dart';
part 'payment_edit_state.dart';

class PaymentEditBloc extends Bloc<PaymentEditEvent, PaymentEditState> {
  PaymentEditBloc(super.initialState);
}
