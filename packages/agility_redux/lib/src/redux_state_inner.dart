import 'redux_state.dart';

/// State used internally
class ReduxStateInner {
  ReduxStateInner({
    Map<String, dynamic> stateMap = const {},
    Map<String, int> stackMap = const {},}
      ) : _stateMap = stateMap, _stackMap = stackMap;

  final Map<String, dynamic> _stateMap;

  final Map<String, int> _stackMap ;

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
    if (stackMap == null || stackMap.isEmpty) {
      stackMap = _stackMap;
    }

    if (stackMap[name] != null) {
      int index = stackMap[name];
      return _stateMap['$name@$index'];
    }
    return null;
  }

  void push(String name) {
    var state = _stateMap['$name@0'];
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
    var state = _stateMap['$name@0'];
    if (state != null && state is ReduxStateItem) {
      if (_stackMap[name] != null) {
        int index = _stackMap[name];
        _stateMap.remove('$name@$index');
        index -= 1;
        if (index >= 0) {
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
