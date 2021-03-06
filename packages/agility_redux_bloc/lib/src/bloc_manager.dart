import 'package:agility_redux/agility_redux.dart';
import 'package:agility_redux_bloc/agility_redux_bloc.dart';
import 'package:agility_redux_bloc/src/bloc_widget.dart';
import 'package:agility_redux_widget/agility_redux_widget.dart';
import 'package:flutter/material.dart';

import 'bloc.dart';
import 'bloc_page.dart';
import 'bloc_popup_box.dart';
import 'bloc_route_settings.dart';

/// Business module manager, singleton
class BlocManager {
  /// Return singleton object
  factory BlocManager() {
    return _instance;
  }

  BlocManager._internal();

  static BlocManager _instance = BlocManager._internal();

  Map<String, Bloc> blocMap = {};

  Map<String, BlocPageBuilder> pageMap = {};
  Map<String, BlocPopupBoxBuilder> popUpBoxMap = {};
  Map<String, BlocWidgetBuilder> widgetMap = {};
  Map<String, BlocFunction> functionMap = {};
  List<ReduxBloc> reduxBlocList = [];

  String pageLayoutType = '';

  /// Update layout type identification,
  /// add @ and type identification after the page name when registering the page
  void updatePageLayoutType(String layoutType) {
    pageLayoutType = layoutType;
  }

  /// Register business module
  void registerBloc(Bloc bloc) {
    if (blocMap[bloc.moduleName] == null) {
      blocMap[bloc.moduleName] = bloc;

      ReduxBloc reduxBloc = bloc.initialReduxBloc();
      reduxBloc.initBloc();
      // Register redux BLoC
      reduxBlocList.add(reduxBloc);
      // Register page
      Map<String, BlocPageBuilder> pageList = bloc.initialPageList();
      for (final String pageName in pageList.keys) {
        if (pageMap['${bloc.moduleName}/$pageName'] == null) {
          pageMap['${bloc.moduleName}/$pageName'] = pageList[pageName];
        } else {
          assert(false, 'same page name');
        }
      }

      // Register popup box
      Map<String, BlocPopupBoxBuilder> popupBoxList = bloc.initialPopupBoxList();
      for (final String popupBoxName in popupBoxList.keys) {
        if (popUpBoxMap['${bloc.moduleName}/$popupBoxName'] == null) {
          popUpBoxMap['${bloc.moduleName}/$popupBoxName'] = popupBoxList[popupBoxName];
        } else {
          assert(false, 'same popup box name');
        }
      }

      // Register widget
      Map<String, BlocWidgetBuilder> widgetList = bloc.initialWidgetList();
      for (final String widgetName in widgetList.keys) {
        if (widgetMap['${bloc.moduleName}/$widgetName'] == null) {
          widgetMap['${bloc.moduleName}/$widgetName'] = widgetList[widgetName];
        } else {
          assert(false, 'same widget name');
        }
      }

      // Register function
      Map<String, BlocFunction> functionList = bloc.initialFunctionList();
      for (final String functionName in functionList.keys) {
        if (functionMap['${bloc.moduleName}/$functionName'] == null) {
          functionMap['${bloc.moduleName}/$functionName'] = functionList[functionName];
        } else {
          assert(false, 'same function name');
        }
      }
    } else {
      assert(false, 'same BLoC name');
    }
  }

  /// Initialize store
  void initStore({
    bool isDebug = false,
  }) {
    List<ReduxBloc> list = [];
    list.addAll(reduxBlocList);

    GlobalStore().initStore(list, isDebug: isDebug);
  }

  /// Send application initialization Action
  void sendAppInitAction(ReduxAction action) {
    GlobalStore().sendAppInitAction(action);
  }

  /// Generate page route, used for navigator
  /// If you use the PageNavigator class, it will handle it automatically
  Route generatePageRoute(RouteSettings settings) {
    var pageBuilder = pageMap['${settings.name}@$pageLayoutType'];
    pageBuilder ??= pageMap[settings.name];
    if (pageBuilder != null) {
      return pageBuilder(BlocRouteSettings(
        name: settings.name,
        arguments: settings.arguments,
        store: GlobalStore().store,
      ));
    }
    return null;
  }

  /// Generate popup box route, used for navigator
  /// If you use the PageNavigator class, it will handle it automatically
  Route generatePopupBoxRoute(RouteSettings settings) {
    BlocPopupBoxBuilder pageBuilder = popUpBoxMap['${settings.name}@$pageLayoutType'];
    pageBuilder ??= popUpBoxMap[settings.name];
    if (pageBuilder != null) {
      return pageBuilder(
        BlocRouteSettings(
          name: settings.name,
          arguments: settings.arguments,
          store: GlobalStore().store,
        ),
      );
    } else {
      return MaterialPageRoute(builder: (BuildContext context) {
        return Container(
          color: Colors.yellow,
          child: Center(
            child: Text(
              'Wrong Route',
              style: TextStyle(fontSize: 60.0),
            ),
          ),
        );
      });
    }
  }

  /// Generate widget
  /// You can use the widget of other modules without import module
  Widget generateWidget(BuildContext context, String widgetName, {Map<String, dynamic> arguments, Widget child}) {
    BlocWidgetBuilder widgetBuilder = widgetMap['$widgetName@$pageLayoutType'];
    widgetBuilder ??= widgetMap[widgetName];
    if (widgetBuilder != null) {
      String parentModelName = ModelNameProvider.of(context);
      Widget realChild = child;
      if (parentModelName != null && parentModelName.isNotEmpty && child != null) {
        realChild = ModelNameProvider(
          blocName: parentModelName,
          child: Builder(
            builder: (BuildContext context) {
              return child;
            },
          ),
        );
      }

      return ModelNameProvider(
        blocName: widgetName.split('/')[0] ?? '',
        child: widgetBuilder(arguments, realChild),
      );
    } else {
      return Container(
        color: Colors.yellow,
        child: Center(
          child: Text(
            'Wrong Widget',
            style: TextStyle(fontSize: 14.0),
          ),
        ),
      );
    }
  }

  Future<dynamic> callFunction(String functionName, {Map<String, dynamic> arguments}) {
    BlocFunction function = functionMap['$functionName'];
    if (function != null) {
      String modelName = functionName.split('/')?.first ?? '';
      return function(arguments, GlobalStore().dispatch, GlobalStore().reduxState(modelName));
    }
    return null;
  }

  /// Reset singleton
  void reset() {
    _instance = BlocManager._internal();
  }
}
