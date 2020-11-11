import 'package:flutter/material.dart';

typedef BlocWidgetBuilder = Widget Function(Map<String, dynamic> arguments, Widget child);

/// Widget that can be exported by a business module
abstract class BlocWidget extends StatelessWidget {
  BlocWidget({
    Key key,
    this.arguments,
    this.child,
  }) : super(key: key);

  final Map<String, dynamic> arguments;
  final Widget child;
}
