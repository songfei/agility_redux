// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:rxdart/subjects.dart' show BehaviorSubject;
import 'package:stack_trace/stack_trace.dart';

import 'redux_action.dart';
import 'redux_bloc.dart';
import 'redux_state_inner.dart';

/// A function that can dispatch an [ReduxAction] to a [ReduxStore].
typedef DispatchFunction = void Function(ReduxAction action);

/// An accumulator for reducer functions.
///
/// [ReduxStore] offers each [ReduxBloc] the opportunity to apply its own reducer
/// functionality in response to incoming [ReduxAction]s by subscribing to the
/// "reducer" stream, which is of type `Stream<Accumulator<S>>`.
///
/// A [ReduxBloc] that does so is expected to use the [ReduxAction] and [state] provided in
/// any [Accumulator] it receives to calculate a new [state], then emit it in a
/// new Accumulator with the original action and new [state]. Alternatively, if
/// the Bloc doesn't want to make a change to the state, it can simply return
/// the Accumulator it was given.
class Accumulator {
  const Accumulator(this.action, this.state);

  final ReduxAction action;
  final ReduxStateInner state;

  Accumulator copyWith(ReduxStateInner newState) => Accumulator(action, newState);
}

/// The context in which a middleware or afterware function executes.
///
/// In a manner similar to the streaming architecture used for reducers, [ReduxStore]
/// offers each [ReduxBloc] the chance to apply middleware and afterware
/// functionality to incoming [Actions] by listening to the "dispatch" stream,
/// which is of type `Stream<WareContext<S>>`.
///
/// Middleware and afterware functions can examine the incoming [action] and
/// current [state] of the app and perform side effects (including dispatching
/// new [ReduxAction]s using [dispatcher]. Afterward, they should emit a new
/// [WareContext] for the next [ReduxBloc].
class WareContext {
  const WareContext(this.dispatcher, this.state, this.action);

  final DispatchFunction dispatcher;
  final ReduxStateInner state;
  final ReduxAction action;

  WareContext copyWith(ReduxAction newAction) => WareContext(dispatcher, state, newAction);
}

/// A store for app state that manages the dispatch of incoming actions and
/// controls the stream of state objects emitted in response.
///
/// [ReduxStore] performs these tasks:
///
/// - Create a controller for the dispatch/reduce stream using an initialState
///   value.
/// - Wire each [ReduxBloc] into the dispatch/reduce stream by calling its
///   applyMiddleware, applyReducers, and applyAfterware methods.
/// - Expose the [dispatch] method with which a new [ReduxAction] can be dispatched.
class ReduxStore {
  ReduxStore({
    List<ReduxBloc<dynamic, dynamic>> blocs = const [],
    this.isDebug = false,
  })  : _blocs = blocs,
        states = BehaviorSubject.seeded(buildState(blocs)) {
    var dispatchStream = _dispatchController.stream.asBroadcastStream();
    var afterwareStream = _afterwareController.stream.asBroadcastStream();

    for (final ReduxBloc<dynamic, dynamic> bloc in blocs) {
      dispatchStream = bloc.applyMiddleware(dispatchStream);
      afterwareStream = bloc.applyAfterware(afterwareStream);
    }

    var reducerStream = dispatchStream.map<Accumulator>((context) => Accumulator(context.action, states.value));

    for (final ReduxBloc<dynamic, dynamic> bloc in blocs) {
      reducerStream = bloc.applyReducer(reducerStream);
    }

    reducerStream.listen((a) {
      assert(a.state != null);
      states.add(a.state);
      _afterwareController.add(WareContext(dispatch, a.state, a.action));
    });

    // Without something listening, the afterware won't be executed.
    afterwareStream.listen((_) {});
  }

  final _dispatchController = StreamController<WareContext>();
  final _afterwareController = StreamController<WareContext>();
  final BehaviorSubject<ReduxStateInner> states;
  final List<ReduxBloc> _blocs;

  final bool isDebug;
  final List<ReduxAction> debugActionList = [];

  static ReduxStateInner buildState(List<ReduxBloc> blocs) {
    Map<String, dynamic> stateMap = <String, dynamic>{};
    for (final v in blocs) {
      dynamic initialState = v.initialState;
      if (initialState != null) {
        stateMap[v.moduleName] = v.initialState;
      }
      dynamic initialPrivateState = v.initialPrivateState;
      if (initialPrivateState != null) {
        stateMap['_${v.moduleName}'] = v.initialPrivateState;
      }
    }
    return ReduxStateInner(stateMap);
  }

  void dispatch(ReduxAction action) {
    action.timestamp = DateTime.now().millisecondsSinceEpoch;
    if (isDebug) {
      action.currentTrace = Trace.current();
      debugActionList.add(action);
    }
    _dispatchController.add(WareContext(dispatch, states.value, action));
  }

  void clearDebugActionList() {
    debugActionList.clear();
  }

  void pushState(String name) {
    states.value.push(name);
    states.value.push('_$name');
  }

  void popState(String name) {
    states.value.pop(name);
    states.value.pop('_$name');
  }

  /// Invokes the dispose method on each Bloc, so they can deallocate/close any
  /// long-lived resources.
  void dispose() {
    for (final b in _blocs) {
      b.dispose();
    }
  }

  @override
  String toString() {
    return 'ReduxStore${states.value}';
  }
}
