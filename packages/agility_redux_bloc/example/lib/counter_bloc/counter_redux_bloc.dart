import 'dart:async';

import 'package:agility_redux_bloc/agility_redux_bloc.dart';
import 'package:logging/logging.dart';

final Logger _log = Logger('CounterReduxBloc');

class CounterAddAction extends ReduxAction {}

class CounterResetAction extends ReduxAction {}

class UpdateCounterNumberAction extends ReduxPrivateAction {
  int number;

  @override
  String get packageName => 'counter';
}

class CounterState extends ReduxStateItem<CounterState> {
  CounterState({
    this.number,
  });
  final int number;

  CounterState copyWith({
    int number,
  }) {
    return CounterState(
      number: number ?? this.number,
    );
  }

  @override
  String toString() {
    return 'CounterState{number: $number}';
  }

  @override
  CounterState clone() {
    return CounterState(number: number);
  }
}

class PrivateCounterState extends ReduxStateItem<PrivateCounterState> {
  @override
  PrivateCounterState clone() {
    return PrivateCounterState();
  }

  @override
  String toString() {
    return 'PrivateCounterState{}';
  }
}

class CounterReduxBloc extends SimpleReduxBloc<CounterState, PrivateCounterState> {
  CounterReduxBloc();

  @override
  String get moduleName => 'counter';

  @override
  CounterState get initialState => CounterState(number: 0);

  @override
  PrivateCounterState get initialPrivateState => PrivateCounterState();

  @override
  void initBloc() {}

  @override
  CounterState reducer(ReduxAction action, CounterState state, PrivateCounterState privateState) {
    CounterState newState = state;

    if (action is UpdateCounterNumberAction) {
      newState = newState.copyWith(
        number: action.number,
      );
    }

    return newState;
  }

  @override
  PrivateCounterState privateReducer(ReduxAction action, CounterState state, PrivateCounterState privateState) {
    PrivateCounterState newPrivateState = privateState;

    return newPrivateState;
  }

  @override
  FutureOr<ReduxAction> middleware(DispatchFunction dispatcher, ReduxState state, ReduxAction action) async {
    //
    if (action is CounterAddAction) {
      CounterState counterState = state.publicState();
      dispatcher(UpdateCounterNumberAction()..number = counterState.number + 1);
    }
    //
    else if (action is CounterResetAction) {
      dispatcher(UpdateCounterNumberAction()..number = 0);
    }
    return action;
  }
}
