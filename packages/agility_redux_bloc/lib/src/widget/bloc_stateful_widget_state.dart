import 'package:agility_redux_widget/agility_redux_widget.dart';
import 'package:flutter/widgets.dart';

/// Add dispatcher, to the initState method and dispose method of StatefulWidget's State
abstract class BlocState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    initStateWithDispatcher(GlobalStore().store.dispatch);
  }

  @protected
  void initStateWithDispatcher(DispatchFunction dispatcher) {}

  @override
  void dispose() {
    disposeWithDispatcher(GlobalStore().store.dispatch);
    super.dispose();
  }

  @protected
  void disposeWithDispatcher(DispatchFunction dispatcher) {}
}
