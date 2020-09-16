import 'redux_state.dart';

/// State used internally
class ReduxStateInner {
  ReduxStateInner(
    Map<String, dynamic> stateMap,
  ) : _stateMap = stateMap;

  final Map<String, dynamic> _stateMap;

  final Map<String, int> _stackMap = {};

  Map<String, int> get stackMap {
    return _stackMap;
  }

  /// Update the state of a module
  void update(String name, dynamic value) {
    if (_stackMap[name] != null) {
      int index = _stackMap[name];
      _stateMap['$name@$index'] = value;
    } else {
      _stateMap[name] = value;
    }
  }

  /// Get the state of a module
  dynamic byName<T>(
    String name, {
    Map<String, int> stackMap,
  }) {
    if (stackMap == null) {
      stackMap = _stackMap;
    }
    if (stackMap[name] != null && stackMap[name] != 0) {
      int index = stackMap[name];
      return _stateMap['$name@$index'];
    }
    return _stateMap[name];
  }

  void push(String name) {
    var state = _stateMap[name];
    if (state != null && state is ReduxStateItem) {
      int index = 0;
      if (_stackMap[name] != null) {
        index = _stackMap[name];
        state = _stateMap['$name@$index'];
      }
      index += 1;
      _stackMap[name] = index;
      _stateMap['$name@$index'] = state.clone();
    }
  }

  void pop(String name) {
    var state = _stateMap[name];
    if (state != null && state is ReduxStateItem) {
      if (_stackMap[name] != null) {
        int index = _stackMap[name];
        _stateMap.remove('$name@$index');
        index -= 1;
        if (index > 0) {
          _stackMap[name] = index;
        } else {
          _stackMap.remove(name);
        }
      }
    }
  }

  @override
  String toString() {
    return '$_stateMap';
  }
}
