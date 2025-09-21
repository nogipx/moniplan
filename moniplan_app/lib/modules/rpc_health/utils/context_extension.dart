import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rpc_dart/rpc_dart.dart';

import '../_index.dart';

extension RpcHealthBlocX on BuildContext {
  RpcHealthBloc get rpcHealthBloc => read<RpcHealthBloc>();
}
