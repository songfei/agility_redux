import 'package:agility_redux/agility_redux.dart';
import 'package:agility_redux_widget/agility_redux_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'bloc_route_settings.dart';

final Logger _log = Logger('BlocPage');

typedef BlocPageBuilder = BlocPageRoute Function(BlocRouteSettings settings);

/// Page route of business module
abstract class BlocPageRoute<T> extends PageRoute<T> {
  BlocPageRoute({
    BlocRouteSettings settings,
    bool fullscreenDialog = false,
  })  : assert(fullscreenDialog != null),
        super(settings: settings, fullscreenDialog: fullscreenDialog) {
    Map<String, dynamic> arguments = settings.arguments ?? {};
    holdBlocNames = arguments['##holdBlocNames##'] ?? [];
    _stackMap = Map.from(GlobalStore().stackMap ?? {});
  }

  DateTime appearTime;
  bool isAppear = false;
  List<String> holdBlocNames;
  Map<String, int> _stackMap;

  @override
  final bool maintainState = true;

  @override
  Duration get transitionDuration {
    Map arguments = settings.arguments as Map;
    if (arguments != null && arguments['disableAnimate'] is bool && arguments['disableAnimate']) {
      return Duration.zero;
    }
    return Duration(milliseconds: 300);
  }

  @override
  Duration get reverseTransitionDuration => Duration(milliseconds: 300);

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return (nextRoute is MaterialPageRoute && !nextRoute.fullscreenDialog) || (nextRoute is CupertinoPageRoute && !nextRoute.fullscreenDialog);
  }

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: StateStackMapProvider(
          stackMap: _stackMap,
          child: ModelNameProvider(
            blocName: name.split('/')[0] ?? '',
            child: buildWithAnimation(context, animation, secondaryAnimation),
          ),
        ));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }

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
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  Widget buildWithAnimation(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return build(context);
  }

  /// Called when the page is initialized
  void init() {}

  /// Called when the page appear
  void appear() {
    appearTime = DateTime.now();
  }

  /// Called when the page disappear
  void disappear() {
    var cost = DateTime.now().difference(appearTime).inMilliseconds;
    _log.info('page costtime $cost');
  }

  @override
  void didChangeNext(Route<dynamic> nextRoute) {
    super.didChangeNext(nextRoute);
    if (nextRoute == null) {
      if (!isAppear) {
        isAppear = true;
        appear();
      }
    } else {
      if (isAppear) {
        isAppear = false;
        disappear();
      }
    }
  }

  @override
  bool didPop(dynamic result) {
//    print('-- ${settings.name} didPop $result');
    if (isAppear) {
      isAppear = false;
      disappear();
    }
    return super.didPop(result);
  }

  @override
  TickerFuture didPush() {
//    print('-- ${settings.name} didPush');
    if (!isAppear) {
      isAppear = true;
      init();
      appear();
    }
    return super.didPush();
  }

  @override
  void didReplace(Route<dynamic> oldRoute) {
    super.didReplace(oldRoute);
//    print('-- ${settings.name} didReplace $oldRoute');
    if (!isAppear) {
      isAppear = true;
      init();
      appear();
    }
  }

  @override
  void didPopNext(Route<dynamic> nextRoute) {
    super.didPopNext(nextRoute);
//    print('-- ${settings.name} didPopNext $nextRoute');
    if (!isAppear) {
      isAppear = true;
      appear();
    }
  }

  @override
  void dispose() {
    holdBlocNames.forEach(GlobalStore().popState);
    super.dispose();
  }
}
