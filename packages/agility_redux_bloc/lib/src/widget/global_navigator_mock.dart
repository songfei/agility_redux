//import 'dart:async';
//import 'dart:collection';
//
//import 'package:flutter/material.dart' hide Stack;
//
//import 'global_navigator_inner.dart';
//
//class PageItem {
//  PageItem({
//    this.name,
//    this.arguments,
//    this.completer,
//  });
//
//  final String name;
//  final Map<String, dynamic> arguments;
//  final Completer completer;
//}
//
//class GlobalNavigatorMock implements GlobalNavigatorInner {
//  ListQueue<PageItem> pageStack = ListQueue<PageItem>();
//  ListQueue<PageItem> popupBoxStack = ListQueue<PageItem>();
//
//  @override
//  List<String> get currentPageList {
//    return pageStack.map((element) => element.name).toList().reversed.toList();
//  }
//
//  @override
//  List<String> get currentPopupBoxList {
//    return popupBoxStack.map((element) => element.name).toList().reversed.toList();
//  }
//
//  @override
//  GlobalKey<NavigatorState> get pageNavigatorKey => null;
//
//  @override
//  GlobalKey<NavigatorState> get popupBoxNavigatorKey => null;
//
//  @override
//  bool get userGestureInProgress => false;
//
//  @override
//  bool canPop() {
//    return pageStack.isNotEmpty;
//  }
//
//  @override
//  bool popupBoxCanPop() {
//    return popupBoxStack.isNotEmpty;
//  }
//
//  @override
//  Future<T> push<T extends Object>(String routeName, {Map<String, dynamic> arguments}) {
//    Completer completer = Completer();
//    pageStack.addLast(PageItem(name: routeName, arguments: arguments, completer: completer));
//    return completer.future;
//  }
//
//  @override
//  Future<T> popupBoxPush<T extends Object>(String routeName, {Map<String, dynamic> arguments}) {
//    Completer completer = Completer();
//    popupBoxStack.addLast(PageItem(name: routeName, arguments: arguments, completer: completer));
//    return completer.future;
//  }
//
//  @override
//  void pop<T extends Object>([T result]) {
//    if (pageStack.isNotEmpty) {
//      PageItem item = pageStack.removeLast();
//      if (item.completer != null) {
//        item.completer.complete(result);
//      }
//    } else {
//      assert(true, '页面栈为空，不能弹出');
//    }
//  }
//
//  @override
//  void popupBoxPop<T extends Object>([T result]) {
//    if (popupBoxStack.isNotEmpty) {
//      PageItem item = popupBoxStack.removeLast();
//      if (item.completer != null) {
//        item.completer.complete(result);
//      }
//    } else {
//      assert(true, '页面栈为空，不能弹出');
//    }
//  }
//
//  @override
//  void popUntil(String routeName) {
//    if (pageStack.isNotEmpty) {
//      String name = '';
//      while (name != routeName && pageStack.isNotEmpty) {
//        if (name != routeName) {
//          pageStack.removeLast();
//        } else {
//          break;
//        }
//      }
//    } else {
//      assert(true, '页面栈为空，不能弹出');
//    }
//  }
//
//  @override
//  void popupBoxPopUntil(String routeName) {
//    if (popupBoxStack.isNotEmpty) {
//      String name = '';
//      while (name != routeName && popupBoxStack.isNotEmpty) {
//        if (name != routeName) {
//          popupBoxStack.removeLast();
//        } else {
//          break;
//        }
//      }
//    } else {
//      assert(true, '页面栈为空，不能弹出');
//    }
//  }
//
//  @override
//  Future<T> popAndPush<T extends Object, TO extends Object>(String routeName, {TO result, Map<String, dynamic> arguments}) {
//    pop(result);
//    return push(routeName, arguments: arguments);
//  }
//
//  @override
//  Future<T> popupBoxPopAndPush<T extends Object, TO extends Object>(String routeName, {TO result, Map<String, dynamic> arguments}) {
//    popupBoxPop(result);
//    return popupBoxPush(routeName, arguments: arguments);
//  }
//
//  @override
//  Future<T> pushAndRemoveUntil<T extends Object>(String newRouteName, String routeName, {Map<String, dynamic> arguments}) {
//    popUntil(routeName);
//    return push(newRouteName, arguments: arguments);
//  }
//
//  @override
//  Future<T> popupBoxPushAndRemoveUntil<T extends Object>(String newRouteName, String routeName, {Map<String, dynamic> arguments}) {
//    popupBoxPopUntil(routeName);
//    return popupBoxPush(newRouteName, arguments: arguments);
//  }
//
//  @override
//  Future<T> pushReplacement<T extends Object, TO extends Object>(String routeName, {TO result, Map<String, dynamic> arguments}) {
//    return popAndPush(routeName, result: result, arguments: arguments);
//  }
//
//  @override
//  Future<T> popupBoxPushReplacement<T extends Object, TO extends Object>(String routeName, {TO result, Map<String, dynamic> arguments}) {
//    return popupBoxPopAndPush(routeName, result: result, arguments: arguments);
//  }
//}
