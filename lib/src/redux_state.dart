import 'redux_state_inner.dart';

abstract class ReduxStateItem<T> {
  T clone();
}

class ReduxState {
  ReduxState({
    this.moduleName,
    ReduxStateInner state,
    Map<String, int> stackMap,
  })  : _reduxStateInner = state,
        _stackMap = stackMap ?? {};

  final String moduleName;
  final ReduxStateInner _reduxStateInner;
  final Map<String, int> _stackMap;

  T byName<T>(String name) {
    if (name.startsWith('_')) {
      return null;
    }
    return _reduxStateInner.byName(
      name,
      stackMap: _stackMap,
    );
  }

  T publicState<T>() {
    return _reduxStateInner.byName(
      moduleName,
      stackMap: _stackMap,
    );
  }

  T privateState<T>() {
    return _reduxStateInner.byName(
      '_$moduleName',
      stackMap: _stackMap,
    );
  }

  @override
  String toString() {
    return 'ReduxState $_reduxStateInner';
  }
}
