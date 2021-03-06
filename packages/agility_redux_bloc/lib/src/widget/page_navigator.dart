import 'package:agility_redux/agility_redux.dart';
import 'package:agility_redux_widget/agility_redux_widget.dart';
import 'package:flutter/material.dart';

import '../bloc_manager.dart';
import '../bloc_page.dart';
import '../bloc_popup_box.dart';
import 'global_navigator.dart';
import 'global_navigator_inner.dart';

/// Application navigator
/// There are two nested navigator, page and popup box
class AppNavigator extends StatelessWidget {
  AppNavigator({
    this.pageNavigatorName = 'page',
    this.popupBoxNavigatorName = 'popupBox',
    this.pageObservers = const [],
    this.popupBoxObservers = const [],
    this.initialPage,
    this.onUnknownRoute,
    this.width,
  });

  final String pageNavigatorName;
  final String popupBoxNavigatorName;
  final List<NavigatorObserver> pageObservers;
  final List<NavigatorObserver> popupBoxObservers;
  final String initialPage;
  final RouteFactory onUnknownRoute;
  final double width;

  @override
  Widget build(BuildContext context) {
    return _AppNavigatorWidthProvider(
      width: width,
      child: WillPopScope(
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
                  ...popupBoxObservers,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Route _onGeneratePopupBoxRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(
        builder: (BuildContext context) {
          Widget child = Navigator(
            key: GlobalNavigatorInner().globalKey(pageNavigatorName),
            onGenerateRoute: _onGeneratePageRoute,
            initialRoute: initialPage,
            observers: [
              _PageNavigatorObserver(
                pageNavigatorName: pageNavigatorName,
              ),
              ...pageObservers,
            ],
          );

          return child;
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
    this.observers = const [],
    this.onUnknownRoute,
  });

  final String pageNavigatorName;
  final List<NavigatorObserver> observers;
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
        ),
        ...observers,
      ],
    );
  }
}

class AppNavigatorContainer extends StatelessWidget {
  AppNavigatorContainer({
    this.child,
    this.background,
  });

  final Widget child;
  final Widget background;

  @override
  Widget build(BuildContext context) {
    double width = _AppNavigatorWidthProvider.of(context);

    if (width != null) {
      Widget widget = Container(
        width: double.infinity,
        child: Center(
          child: SizedBox(
            width: width,
            height: double.infinity,
            child: ClipRect(
              child: child,
            ),
          ),
        ),
      );

      if (background == null) {
        return widget;
      } else {
        return Stack(
          fit: StackFit.expand,
          children: [
            background,
            widget,
          ],
        );
      }
    } else {
      return child;
    }
  }
}

class _PageNavigatorObserver extends NavigatorObserver {
  _PageNavigatorObserver({
    this.pageNavigatorName,
  });

  final String pageNavigatorName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is BlocPageRoute || route is BlocPopupBoxRoute) {
      GlobalNavigator().currentPageChangedNotification.add(pageNavigatorName);
      GlobalNavigator().history(pageNavigatorName).add(
            HistoryItem.create(
              name: route.settings.name,
              arguments: route.settings.arguments,
            ),
          );
    }
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    if (newRoute is BlocPageRoute || newRoute is BlocPopupBoxRoute) {
      GlobalNavigator().currentPageChangedNotification.add(pageNavigatorName);

      List<HistoryItem> history = GlobalNavigator().history(pageNavigatorName);
      history.removeLast();
      history.add(
        HistoryItem.create(
          name: newRoute.settings.name,
          arguments: newRoute.settings.arguments,
        ),
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is BlocPageRoute || route is BlocPopupBoxRoute) {
      GlobalNavigator().currentPageChangedNotification.add(pageNavigatorName);
      List<HistoryItem> history = GlobalNavigator().history(pageNavigatorName);
      history.removeWhere((element) => element.name == route.settings.name);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is BlocPageRoute || route is BlocPopupBoxRoute) {
      GlobalNavigator().currentPageChangedNotification.add(pageNavigatorName);
      List<HistoryItem> history = GlobalNavigator().history(pageNavigatorName);
      history.removeLast();
    }
  }
}

class _AppNavigatorWidthProvider extends InheritedWidget {
  _AppNavigatorWidthProvider({
    Key key,
    this.width,
    Widget child,
  }) : super(key: key, child: child);

  final double width;

  static double of(BuildContext context) {
    _AppNavigatorWidthProvider widget = context.dependOnInheritedWidgetOfExactType<_AppNavigatorWidthProvider>();
    return widget?.width;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
