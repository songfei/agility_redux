class ReduxStateInner {
  ReduxStateInner(Map<String, dynamic> stateMap) : _stateMap = stateMap;

  final Map<String, dynamic> _stateMap;

  final Map<String, int> _stackMap = {};

  void update(String name, dynamic value) {
    _stateMap[name] = value;
  }

  dynamic byName(String name) {
    return _stateMap[name];
  }

  void push(String name) {
    if (_stateMap[name] != null) {
      int index = 0;
      if (_stackMap[name] != null) {
        index = _stackMap[name];
      }
      index += 1;
      _stackMap[name] = index;

      _stateMap['$name@$index'] = _stateMap[name].

    }
  }

  void pop(String name) {}
}
