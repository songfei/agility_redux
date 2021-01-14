import 'dart:async';

import 'package:agility_redux/agility_redux_inner.dart';
import 'package:flutter/widgets.dart';

typedef ReceivedActionFunction<T> = Function(T action);

class ActionSubscriber<T> extends StatefulWidget {
  ActionSubscriber({
    this.onReceivedAction,
    this.child,
  });

  @override
  State<StatefulWidget> createState() => ActionSubscriberState<T>();

  final ReceivedActionFunction<T> onReceivedAction;
  final Widget child;
}

class ActionSubscriberState<T> extends State<ActionSubscriber<T>> {
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.onReceivedAction != null) {
      _streamSubscription = GlobalStore().actionListener.listen((event) {
        if (event is T) {
          var action = event as T;
          widget.onReceivedAction(action);
        }
      });
    }
  }

  @override
  void dispose() {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return widget.child;
    }
    return Container();
  }
}
