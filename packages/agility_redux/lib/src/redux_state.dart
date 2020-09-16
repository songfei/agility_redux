import 'redux_state_inner.dart';

/// The state of each module needs to implement the clone method
abstract class ReduxStateItem<T> {
  T clone();
}

/// State of a specific module
class ReduxState {
  ReduxState({
    this.moduleName,
    ReduxStateInner state,
    Map<String, int> stackMap,
  })  : _reduxStateInner = state,
        _stackMap = stackMap;

  final String moduleName;
  final ReduxStateInner _reduxStateInner;
  final Map<String, int> _stackMap;

  /// Get the public state of other modules
  T byName<T>(String name) {
    if (name.startsWith('_')) {
      return null;
    }
    return _reduxStateInner.byName(
      name,
      stackMap: _stackMap,
    );
  }

  /// Get the public state of this module
  T publicState<T>() {
    return _reduxStateInner.byName(
      moduleName,
      stackMap: _stackMap,
    );
  }

  /// Get the private state of this module
  T privateState<T>() {
    return _reduxStateInner.byName(
      '_$moduleName',
      stackMap: _stackMap,
    );
  }

  @override
  String toString() {
    return 'ReduxState[$_stackMap] $_reduxStateInner';
  }
}
