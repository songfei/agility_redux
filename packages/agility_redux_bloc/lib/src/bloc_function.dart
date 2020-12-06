import 'package:agility_redux/agility_redux.dart';

typedef BlocFunction = Future<dynamic> Function(Map<String, dynamic> arguments, DispatchFunction dispatcher, ReduxState state);

