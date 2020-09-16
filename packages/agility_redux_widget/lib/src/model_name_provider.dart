import 'package:flutter/material.dart';

class ModelNameProvider extends InheritedWidget {
  ModelNameProvider({
    Key key,
    this.blocName,
    Widget child,
  }) : super(key: key, child: child);

  final String blocName;

  static String of(BuildContext context) {
    ModelNameProvider widget = context.dependOnInheritedWidgetOfExactType<ModelNameProvider>();
    return widget.blocName;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
