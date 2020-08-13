import 'dart:async';

import 'package:meta/meta.dart';

import 'redux_action.dart';
import 'redux_state.dart';
import 'redux_store.dart';

/// A business logic component that can apply middleware, reducer, and
/// afterware functionality to a [ReduxStore] by transforming the streams passed into
/// its [applyMiddleware], [applyReducer], and [applyAfterware] methods.
abstract class ReduxBloc<S, T> {
  String get moduleName => runtimeType.toString();

  S get initialState => null;
  T get initialPrivateState => null;

  void initBloc();

  Stream<WareContext> applyMiddleware(Stream<WareContext> input);

  Stream<Accumulator> applyReducer(Stream<Accumulator> input);

  Stream<WareContext> applyAfterware(Stream<WareContext> input);

  void dispose();
}

/// A convenience [ReduxBloc] class that handles the stream mapping bits for you.
/// Subclasses can simply override [middleware], [reducer], and [afterware] to
/// add their implementations.
abstract class SimpleReduxBloc<S, T> implements ReduxBloc<S, T> {
  @override
  Stream<WareContext> applyMiddleware(Stream<WareContext> input) {
    return input.asyncMap((context) async {
      if (context.action is ReduxPrivateAction && context.action.packageName != moduleName) {
        return context;
      }
      return context.copyWith(await middleware(
        context.dispatcher,
        ReduxState(moduleName: moduleName, state: context.state),
        context.action,
      ));
    });
  }

  @override
  Stream<Accumulator> applyReducer(Stream<Accumulator> input) {
    return input.map<Accumulator>((accumulator) {
      dynamic moduleState = accumulator.state.stateMap[moduleName];
      dynamic privateModuleState = accumulator.state.stateMap['_$moduleName'];
      if (moduleState is S) {
        accumulator.state.stateMap[moduleName] = reducer(accumulator.action, moduleState, privateModuleState);
      }
      if (privateModuleState is T) {
        if (!(accumulator.action is ReduxPrivateAction && accumulator.action.packageName != moduleName)) {
          accumulator.state.stateMap['_$moduleName'] = privateReducer(accumulator.action, moduleState, privateModuleState);
        }
      }
      return accumulator.copyWith(accumulator.state);
    });
  }

  @override
  Stream<WareContext> applyAfterware(Stream<WareContext> input) {
    return input.asyncMap((context) async {
      if (context.action is ReduxPrivateAction && context.action.packageName != moduleName) {
        return context;
      }
      return context.copyWith(await afterware(
        context.dispatcher,
        ReduxState(moduleName: moduleName, state: context.state),
        context.action,
      ));
    });
  }

  FutureOr<ReduxAction> middleware(DispatchFunction dispatcher, ReduxState state, ReduxAction action) => action;

  FutureOr<ReduxAction> afterware(DispatchFunction dispatcher, ReduxState state, ReduxAction action) => action;

  S reducer(ReduxAction action, S state, T privateState) => state;

  T privateReducer(ReduxAction action, S state, T privateState) => privateState;

  @mustCallSuper
  @override
  void dispose() {}
}
