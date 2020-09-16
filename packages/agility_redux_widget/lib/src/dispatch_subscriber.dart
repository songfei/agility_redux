import 'package:agility_redux/agility_redux_inner.dart';
import 'package:flutter/material.dart';

import 'store_provider.dart';

/// Widget builder function that includes a [dispatcher] capable of dispatching
/// an [Action] to an inherited Store.
typedef DispatchWidgetBuilder = Widget Function(BuildContext context, DispatchFunction dispatcher);

/// Retrieves a DispatcherFunction] from an ancestor [StoreProvider], and
/// builds builds widgets that can use it.
///
/// [DispatchSubscriber] is essentially a ViewModelSubscriber without the view
/// model part. It looks among its ancestors for a Store of the correct type,
/// and then builds widgets via a builder function that accepts the Store's
/// dispatcher property as one of its parameters.
class DispatchSubscriber<S> extends StatelessWidget {
  DispatchSubscriber({
    @required this.builder,
    Key key,
  }) : super(key: key);

  final DispatchWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of(context);
    return builder(context, store.dispatch);
  }
}
