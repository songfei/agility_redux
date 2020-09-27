import 'package:agility_redux_bloc/agility_redux_bloc.dart';

import '../counter_redux_bloc.dart';

class CounterViewModel extends ReduxViewModel {
  CounterViewModel({
    this.number,
  });

  factory CounterViewModel.fromState(ReduxState state) {
    CounterState publicState = state.publicState<CounterState>();
    return CounterViewModel(number: publicState.number);
  }
  final int number;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CounterViewModel && runtimeType == other.runtimeType && number == other.number;

  @override
  int get hashCode => number.hashCode;
}
