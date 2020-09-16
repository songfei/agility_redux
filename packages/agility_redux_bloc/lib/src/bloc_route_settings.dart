import 'package:agility_redux_widget/agility_redux_widget.dart';
import 'package:flutter/widgets.dart';

/// Data that might be useful in constructing a [Route].
class BlocRouteSettings extends RouteSettings {
  BlocRouteSettings({
    String name,
    Map<String, dynamic> arguments,
    this.store,
  }) : super(name: name, arguments: arguments);

  final ReduxStore store;
}
