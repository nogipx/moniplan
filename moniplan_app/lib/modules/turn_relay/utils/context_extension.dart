import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/turn_relay_bloc.dart';

extension TurnRelayBlocX on BuildContext {
  TurnRelayBloc get turnRelayBloc => read<TurnRelayBloc>();
}
