import 'package:agility_redux/agility_redux.dart';
import 'package:agility_redux_widget/agility_redux_widget.dart';
import 'package:flutter/material.dart';

import 'bloc_route_settings.dart';

typedef BlocPopupBoxBuilder = BlocPopupBoxRoute Function(BlocRouteSettings settings);

/// Popup box route of business module
abstract class BlocPopupBoxRoute<T> extends ModalRoute<T> {
  BlocPopupBoxRoute({BlocRouteSettings settings}) : super(settings: settings);

  String get name {
    return settings.name;
  }

  Map<String, dynamic> get arguments {
    return settings.arguments;
  }

  ReduxStore get store {
    BlocRouteSettings blocSettings = settings;
    return blocSettings.store;
  }

  @override
  Color get barrierColor => Color.fromRGBO(0, 0, 0, 0.1);

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => '';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2,
      child: ModelNameProvider(
        blocName: name.split('/')[0] ?? '',
        child: build(context),
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  Widget build(BuildContext context);
}
