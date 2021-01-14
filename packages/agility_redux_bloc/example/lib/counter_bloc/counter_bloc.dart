import 'package:agility_redux_bloc/agility_redux_bloc.dart';
import 'package:flutter/material.dart';

import 'actionsheet/action_sheet_popup_box.dart';
import 'counter_page/counter_page.dart';
import 'counter_redux_bloc.dart';

class CounterBloc extends Bloc {
  @override
  String moduleName = 'counter';

  @override
  ReduxBloc initialReduxBloc() {
    return CounterReduxBloc();
  }

  @override
  Map<String, BlocPageBuilder> initialPageList() {
    return {
      'counter_page': (RouteSettings settings) => CounterPage(settings: settings),
    };
  }

  @override
  Map<String, BlocPopupBoxBuilder> initialPopupBoxList() {
    return {
      'action_sheet': (RouteSettings settings) => ActionSheetPopupBox(settings: settings),
    };
  }
}
