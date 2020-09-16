import 'dart:async';

import 'package:agility_redux_widget/agility_redux_widget.dart';
import 'package:flutter/widgets.dart';

import 'global_navigator_inner.dart';

/// Represents a global navigator, because there may be multiple navigator in the application
class GlobalNavigatorEntry {
  GlobalNavigatorEntry({
    this.state,
  });

  final NavigatorState state;

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
    Map<String, dynamic> newArguments = Map.from(arguments ?? {});
    newArguments['##holdBlocNames##'] = holdBlocNames;
    holdBlocNames.forEach(GlobalStore().pushState);

    return state.pushNamedAndRemoveUntil<T>(
      newRouteName,
      (route) => route.settings.name == routeName,
      arguments: arguments,
    );
  }

  Future<T> pushReplacement<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    Map<String, dynamic> arguments,
    List<String> holdBlocNames = const [],
  }) {
    Map<String, dynamic> newArguments = Map.from(arguments ?? {});
    newArguments['##holdBlocNames##'] = holdBlocNames;
    holdBlocNames.forEach(GlobalStore().pushState);
    return state.pushReplacementNamed<T, TO>(routeName, result: result, arguments: arguments);
  }

  void pop<T extends Object>([T result]) {
    state.pop<T>(result);
  }

  Future<T> popAndPush<T extends Object, TO extends Object>(String routeName, {TO result, Map<String, dynamic> arguments}) {
    return state.popAndPushNamed<T, TO>(routeName, result: result, arguments: arguments);
  }

  void popUntil(String routeName) {
    state.popUntil((route) => route.settings.name == routeName);
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

  List<String> history(String key) {
    return _innerNavigator.history(key);
  }

  void dispose() {
    currentPageChangedNotification.close();
  }
}
