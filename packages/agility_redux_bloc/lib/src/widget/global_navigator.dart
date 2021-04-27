import 'dart:async';

import 'package:agility_redux/agility_redux.dart';
import 'package:flutter/widgets.dart';

import 'global_navigator_inner.dart';

/// Represents a global navigator, because there may be multiple navigator in the application
class GlobalNavigatorEntry {
  GlobalNavigatorEntry({
    this.key,
    this.state,
  });

  final NavigatorState state;
  final String key;

  bool get userGestureInProgress {
    return state.userGestureInProgress;
  }

  bool canPop() {
    return state.canPop();
  }

  Future<T> push<T extends Object>(
    String routeName, {
    Map<String, dynamic> arguments,
    List<String> holdBlocNames = const [],
  }) {
    if (_isSameTopRoute(routeName, arguments)) {
      return null;
    }
    Map<String, dynamic> newArguments = Map.from(arguments ?? {});
    newArguments['##holdBlocNames##'] = holdBlocNames;
    holdBlocNames.forEach(GlobalStore().pushState);
    return state.pushNamed<T>(routeName, arguments: newArguments);
  }

  Future<T> pushAndRemoveUntil<T extends Object>(
    String newRouteName,
    String routeName, {
    Map<String, dynamic> arguments,
    List<String> holdBlocNames = const [],
  }) {
    if (_isSameTopRoute(newRouteName, arguments)) {
      return null;
    }
    Map<String, dynamic> newArguments = Map.from(arguments ?? {});
    newArguments['##holdBlocNames##'] = holdBlocNames;
    holdBlocNames.forEach(GlobalStore().pushState);

    return state.pushNamedAndRemoveUntil<T>(
      newRouteName,
      (route) => route.settings.name == routeName,
      arguments: newArguments,
    );
  }

  Future<T> pushReplacement<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    Map<String, dynamic> arguments,
    List<String> holdBlocNames = const [],
  }) {
    if (_isSameTopRoute(routeName, arguments)) {
      return null;
    }
    Map<String, dynamic> newArguments = Map.from(arguments ?? {});
    newArguments['##holdBlocNames##'] = holdBlocNames;
    holdBlocNames.forEach(GlobalStore().pushState);
    return state.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: newArguments,
    );
  }

  Future<T> pushOrReplacement<T extends Object, TO extends Object>(
    String routeName,
    String replaceRouteName, {
    TO result,
    Map<String, dynamic> arguments,
    List<String> holdBlocNames = const [],
  }) {
    if (_isSameTopRoute(routeName, arguments)) {
      return null;
    }
    Map<String, dynamic> newArguments = Map.from(arguments ?? {});
    newArguments['##holdBlocNames##'] = holdBlocNames;
    holdBlocNames.forEach(GlobalStore().pushState);

    if (_topRouteName == replaceRouteName) {
      newArguments['disableAnimate'] = true;
      return state.pushReplacementNamed<T, TO>(
        routeName,
        result: result,
        arguments: newArguments,
      );
    } else {
      return state.pushNamed<T>(
        routeName,
        arguments: newArguments,
      );
    }
  }

  void pop<T extends Object>([T result]) {
    state.pop<T>(result);
  }

  void maybePop<T extends Object>(String routeName, [T result]) {
    if (_topRouteName == routeName) {
      state.pop<T>(result);
    }
  }

  Future<T> popAndPush<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    Map<String, dynamic> arguments,
    List<String> holdBlocNames = const [],
  }) {
    Map<String, dynamic> newArguments = Map.from(arguments ?? {});
    newArguments['##holdBlocNames##'] = holdBlocNames;
    holdBlocNames.forEach(GlobalStore().pushState);
    return state.popAndPushNamed<T, TO>(
      routeName,
      result: result,
      arguments: newArguments,
    );
  }

  void popUntil(String routeName) {
    state.popUntil((route) => route.settings.name == routeName);
  }

  String get _topRouteName {
    List<HistoryItem> historyList = GlobalNavigator().history(key);
    if (historyList != null && historyList.isNotEmpty) {
      return historyList.last.name;
    }
    return '';
  }

  bool _isSameTopRoute(String name, Map<String, dynamic> arguments) {
    List<HistoryItem> historyList = GlobalNavigator().history(key);
    if (historyList != null && historyList.isNotEmpty) {
      HistoryItem item = historyList.last;
      return item.name == name && item.argumentsKey == generateArgumentsKey(arguments);
    }
    return false;
  }
}

/// Global navigator, there may be multiple navigators
class GlobalNavigator {
  factory GlobalNavigator() {
    return _instance;
  }

  GlobalNavigator._internal() {
    _innerNavigator.addGlobalNavigator('page');
    _innerNavigator.addGlobalNavigator('popupBox');
  }

  static GlobalNavigator _instance = GlobalNavigator._internal();

  GlobalNavigatorInner _innerNavigator = GlobalNavigatorInner();

  bool disablePop = false;

  StreamController<String> currentPageChangedNotification = StreamController<String>.broadcast();

//  // 是否调试模式
//  bool _isDebug = false;
//
//  set isDebug(bool isDebug) {
//    _isDebug = isDebug;
//    if (isDebug) {
//      _innerNavigator = GlobalNavigatorMock();
//    } else {
//      _innerNavigator = GlobalNavigatorInner();
//    }
//  }
//
//  bool get isDebug {
//    return _isDebug;
//  }

  void addGlobalNavigator(String key) {
    _innerNavigator.addGlobalNavigator(key);
  }

  GlobalNavigatorEntry navigatorEntry(String key) {
    return _innerNavigator.navigatorEntry(key);
  }

  List<HistoryItem> history(String key) {
    return _innerNavigator.history(key);
  }

  void dispose() {
    currentPageChangedNotification.close();
  }
}
