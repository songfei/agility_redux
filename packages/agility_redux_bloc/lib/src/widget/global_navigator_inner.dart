import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'global_navigator.dart';

class HistoryItem {
  HistoryItem({
    this.name,
    this.argumentsKey,
  });

  factory HistoryItem.create({
    String name,
    Map<String, dynamic> arguments,
  }) {
    return HistoryItem(
      name: name,
      argumentsKey: generateArgumentsKey(arguments),
    );
  }

  final String name;
  final String argumentsKey;
}

Map<String, dynamic> _cleanMap(Map<String, dynamic> arguments) {
  return arguments.map((key, value) {
    if (!(value is String)) {
      return MapEntry(key, value.hashCode.toString());
    }
    return MapEntry(key, value);
  });
}

String generateArgumentsKey(Map<String, dynamic> arguments) {
  String argumentsKey = '';
  if (arguments != null) {
    arguments.remove('##holdBlocNames##');

    var argumentsString = jsonEncode(_cleanMap(arguments));
    var bytes = utf8.encode(argumentsString);
    var digest = sha1.convert(bytes);
    argumentsKey = '$digest';
  }

  return argumentsKey;
}

/// Global navigator for internal use
class GlobalNavigatorInner {
  factory GlobalNavigatorInner() {
    return _instance;
  }

  GlobalNavigatorInner._internal();

  static final GlobalNavigatorInner _instance = GlobalNavigatorInner._internal();

  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {};
  final Map<String, List<HistoryItem>> _historyMap = {};

  void addGlobalNavigator(String key) {
    _navigatorKeys[key] = GlobalKey<NavigatorState>();
    _historyMap[key] = [];
  }

  GlobalKey<NavigatorState> globalKey(String key) {
    return GlobalNavigatorInner()._navigatorKeys[key];
  }

  List<HistoryItem> history(String key) {
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
