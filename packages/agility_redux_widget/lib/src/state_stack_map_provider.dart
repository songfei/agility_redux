import 'package:flutter/material.dart';

class StateStackMapProvider extends InheritedWidget {
  StateStackMapProvider({
    Key key,
    this.stackMap,
    Widget child,
  }) : super(key: key, child: child);

  final Map<String, int> stackMap;

  static Map<String, int> of(BuildContext context) {
    StateStackMapProvider widget = context.dependOnInheritedWidgetOfExactType<StateStackMapProvider>();
    return widget?.stackMap;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
