import 'package:agility_redux_bloc/agility_redux_bloc.dart';
import 'package:flutter/material.dart';

import 'action_sheet_widget.dart';

class ActionSheetPopupBox extends BlocSidePopupBoxRoute {
  ActionSheetPopupBox({
    BlocRouteSettings settings,
  }) : super(settings: settings);

  // @override
  Color get barrierColor => Colors.black.withOpacity(0.7);

  @override
  bool get barrierDismissible => true;

  @override
  Widget build(BuildContext context) {
    return ActionSheetWidget(
      actionList: ['测试一下', '测试两下'],
      highlightIndex: 1,
    );
  }
}
