import 'package:agility_redux/agility_redux.dart';

class ReduxStateInner {
  ReduxStateInner(
    Map<String, dynamic> stateMap,
  ) : _stateMap = stateMap;

  final Map<String, dynamic> _stateMap;

  final Map<String, int> _stackMap = {};

  void update(String name, dynamic value) {
    _stateMap[name] = value;
  }

  dynamic byName<T>(String name) {
    return _stateMap[name];
  }

  void push(String name) {
    var state = _stateMap[name];
    if (state != null && state is ReduxStateItem) {
      int index = 0;
      if (_stackMap[name] != null) {
        index = _stackMap[name];
      }
      index += 1;
      _stackMap[name] = index;
      _stateMap['$name@$index'] = _stateMap[name].clone();
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
}
