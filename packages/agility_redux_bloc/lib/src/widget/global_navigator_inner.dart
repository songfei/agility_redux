import 'package:flutter/material.dart';

import 'global_navigator.dart';

/// Global navigator for internal use
class GlobalNavigatorInner {
  factory GlobalNavigatorInner() {
    return _instance;
  }

  GlobalNavigatorInner._internal();

  static final GlobalNavigatorInner _instance = GlobalNavigatorInner._internal();

  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {};
  final Map<String, List<String>> _historyMap = {};

  void addGlobalNavigator(String key) {
    _navigatorKeys[key] = GlobalKey<NavigatorState>();
    _historyMap[key] = [];
  }

  GlobalKey<NavigatorState> globalKey(String key) {
    return GlobalNavigatorInner()._navigatorKeys[key];
  }

  List<String> history(String key) {
    return _historyMap[key];
  }

  NavigatorState navigatorState(String key) {
    return globalKey(key)?.currentState;
  }

  GlobalNavigatorEntry navigatorEntry(String key) {
    NavigatorState state = navigatorState(key);
    if (state != null) {
      return GlobalNavigatorEntry(state: state, key: key);
    }
    return null;
  }
}
