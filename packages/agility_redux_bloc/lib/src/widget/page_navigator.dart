import 'package:agility_redux/agility_redux.dart';
import 'package:agility_redux_widget/agility_redux_widget.dart';
import 'package:flutter/material.dart';

import '../bloc_manager.dart';
import 'global_navigator.dart';
import 'global_navigator_inner.dart';

/// Application navigator
/// There are two nested navigator, page and popup box
class AppNavigator extends StatelessWidget {
  AppNavigator({
    this.pageNavigatorName = 'page',
    this.popupBoxNavigatorName = 'popupBox',
    this.initialPage,
    this.onUnknownRoute,
  });

  final String pageNavigatorName;
  final String popupBoxNavigatorName;
  final String initialPage;
  final RouteFactory onUnknownRoute;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _canNavigatorPop,
      child: Builder(
        builder: (BuildContext context) {
          return StoreProvider(
            store: GlobalStore().store,
            child: Navigator(
              key: GlobalNavigatorInner().globalKey(popupBoxNavigatorName),
              onGenerateRoute: _onGeneratePopupBoxRoute,
              observers: [
                _PageNavigatorObserver(
                  pageNavigatorName: popupBoxNavigatorName,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Route _onGeneratePopupBoxRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return Navigator(
            key: GlobalNavigatorInner().globalKey(pageNavigatorName),
            onGenerateRoute: _onGeneratePageRoute,
            initialRoute: initialPage,
            observers: [
              _PageNavigatorObserver(
                pageNavigatorName: pageNavigatorName,
              ),
            ],
          );
        },
      );
    } else {
      return BlocManager().generatePopupBoxRoute(settings);
    }
  }

  Route _onGeneratePageRoute(RouteSettings settings) {
    Route route = BlocManager().generatePageRoute(settings);
    return route ??= onUnknownRoute(settings);
  }

  Future<bool> _canNavigatorPop() async {
    return !GlobalNavigator().disablePop;
  }
}

/// Navigator within the application
/// Usually used as a non-fullscreen navigator on a large screen
class PageNavigator extends StatelessWidget {
  PageNavigator({
    @required this.pageNavigatorName,
    @required this.initialPage,
    this.onUnknownRoute,
  });

  final String pageNavigatorName;
  final String initialPage;
  final RouteFactory onUnknownRoute;

  Route _onGeneratePageRoute(RouteSettings settings) {
    Route route = BlocManager().generatePageRoute(settings);
    if (onUnknownRoute != null) {
      route ??= onUnknownRoute(settings);
    }
    return route;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalNavigatorInner().globalKey(pageNavigatorName),
      initialRoute: initialPage,
      onGenerateRoute: _onGeneratePageRoute,
      observers: [
        _PageNavigatorObserver(
          pageNavigatorName: pageNavigatorName,
        )
      ],
    );
  }
}

class _PageNavigatorObserver extends NavigatorObserver {
  _PageNavigatorObserver({
    this.pageNavigatorName,
  });

  final String pageNavigatorName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    GlobalNavigator().currentPageChangedNotification.add(pageNavigatorName);
    GlobalNavigator().history(pageNavigatorName).add(route.settings.name);
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    GlobalNavigator().currentPageChangedNotification.add(pageNavigatorName);

    List<String> history = GlobalNavigator().history(pageNavigatorName);
    history.removeLast();
    history.add(newRoute.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    GlobalNavigator().currentPageChangedNotification.add(pageNavigatorName);
    List<String> history = GlobalNavigator().history(pageNavigatorName);
    history.removeWhere((element) => element == route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    GlobalNavigator().currentPageChangedNotification.add(pageNavigatorName);
    List<String> history = GlobalNavigator().history(pageNavigatorName);
    history.removeLast();
  }
}
