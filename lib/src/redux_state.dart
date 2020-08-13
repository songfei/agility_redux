import 'redux_state_inner.dart';

class ReduxState {
  ReduxState({
    this.moduleName,
    ReduxStateInner state,
  }) : _reduxStateInner = state;

  final String moduleName;
  final ReduxStateInner _reduxStateInner;

  T byName<T>(String name) {
    if (name.startsWith('_')) {
      return null;
    }
    return _reduxStateInner.stateMap[name];
  }

  T publicState<T>() {
    return _reduxStateInner.stateMap[moduleName];
  }

  T privateState<T>() {
    return _reduxStateInner.stateMap['_$moduleName'];
  }

  @override
  String toString() {
    return 'ReduxState ${_reduxStateInner.stateMap}';
  }
}
