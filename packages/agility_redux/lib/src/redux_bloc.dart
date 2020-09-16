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
//      if (context.action is ReduxPrivateAction && context.action.packageName != moduleName) {
//        return context;
//      }
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
      dynamic moduleState = accumulator.state.byName(moduleName);
      dynamic privateModuleState = accumulator.state.byName('_$moduleName');
      if (moduleState is S) {
        accumulator.state.update(moduleName, reducer(accumulator.action, moduleState, privateModuleState));
      }
      if (privateModuleState is T) {
//        if (!(accumulator.action is ReduxPrivateAction && accumulator.action.packageName != moduleName)) {
        accumulator.state.update('_$moduleName', privateReducer(accumulator.action, moduleState, privateModuleState));
//        }
      }
      return accumulator.copyWith(accumulator.state);
    });
  }

  @override
  Stream<WareContext> applyAfterware(Stream<WareContext> input) {
    return input.asyncMap((context) async {
//      if (context.action is ReduxPrivateAction && context.action.packageName != moduleName) {
//        return context;
//      }
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

typedef TypedReducerFunction<S, T> = S Function(ReduxAction action, S newState, T privateState);
typedef TypedPrivateReducerFunction<S, T> = T Function(ReduxAction action, S state, T newPrivateState);
typedef TypedMiddlewareFunction = FutureOr<void> Function(DispatchFunction dispatcher, ReduxState state, ReduxAction action);

abstract class TypedReduxBloc<S, T> extends SimpleReduxBloc<S, T> {
  TypedReduxBloc();

  Map<Type, TypedReducerFunction<S, T>> _reducerMap = {};
  Map<Type, TypedPrivateReducerFunction<S, T>> _privateReducerMap = {};
  Map<Type, TypedMiddlewareFunction> _middlewareMap = {};
  Map<Type, TypedMiddlewareFunction> _afterwareMap = {};

  void registerReducer(Type actionType, TypedReducerFunction<S, T> callback) {
    _reducerMap[actionType] = callback;
  }

  void registerPrivateReducer(Type actionType, TypedPrivateReducerFunction<S, T> callback) {
    _privateReducerMap[actionType] = callback;
  }

  void registerMiddleware(Type actionType, TypedMiddlewareFunction callback) {
    _middlewareMap[actionType] = callback;
  }

  void registerAfterware(Type actionType, TypedMiddlewareFunction callback) {
    _afterwareMap[actionType] = callback;
  }

  @override
  S reducer(ReduxAction action, S state, T privateState) {
    S newState = state;
    _reducerMap.forEach((Type type, TypedReducerFunction<S, T> callback) {
      if (action.runtimeType == type.runtimeType) {
        newState = callback(action, newState, privateState);
      }
    });
    return newState;
  }

  @override
  T privateReducer(ReduxAction action, S state, T privateState) {
    T newState = privateState;
    _privateReducerMap.forEach((Type type, TypedPrivateReducerFunction<S, T> callback) {
      if (action.runtimeType == type.runtimeType) {
        newState = callback(action, state, newState);
      }
    });
    return newState;
  }

  @override
  FutureOr<ReduxAction> middleware(dispatcher, ReduxState state, ReduxAction action) {
    _middlewareMap.forEach((Type type, TypedMiddlewareFunction callback) {
      if (action.runtimeType == type.runtimeType) {
        callback(dispatcher, state, action);
      }
    });
    return action;
  }

  @override
  FutureOr<ReduxAction> afterware(dispatcher, ReduxState state, ReduxAction action) {
    _afterwareMap.forEach((Type type, TypedMiddlewareFunction callback) {
      if (action.runtimeType == type.runtimeType) {
        callback(dispatcher, state, action);
      }
    });
    return action;
  }

  void initReducer();
  void initPrivateReducer();
  void initMiddleware();
  void initAfterware();
}
