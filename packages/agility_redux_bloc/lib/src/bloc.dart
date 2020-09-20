import 'package:agility_redux/agility_redux.dart';

import 'bloc_page.dart';
import 'bloc_popup_box.dart';
import 'bloc_widget.dart';

/// Represents a pluggable business module
abstract class Bloc {
  /// Used to identify the module and cannot be repeated.
  String moduleName;

  /// Return the list of registered pages
  Map<String, BlocPageBuilder> initialPageList() {
    return {};
  }

  /// Return the list of registered popup boxes
  Map<String, BlocPopupBoxBuilder> initialPopupBoxList() {
    return {};
  }

  /// Return the list of registered widgets
  Map<String, BlocWidgetBuilder> initialWidgetList() {
    return {};
  }

  /// Return ReduxBloc object of this module
  ReduxBloc initialReduxBloc();
}
