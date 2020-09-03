import 'redux_state_inner.dart';

class GeneratedMessage {
  int a;

  GeneratedMessage clone() {
    return this;
  }
}

class ttt extends GeneratedMessage with ReduxStateItem<GeneratedMessage> {}

abstract class ReduxStateItem<T> {
  T clone();
}

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
    return _reduxStateInner.byName(name);
  }

  T publicState<T>() {
    return _reduxStateInner.byName(moduleName);
  }

  T privateState<T>() {
    return _reduxStateInner.byName('_$moduleName');
  }

  @override
  String toString() {
    return 'ReduxState $_reduxStateInner';
  }
}
