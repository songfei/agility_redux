import 'package:flutter/material.dart';

import '../redux_store.dart';

/// A [StatelessWidget] that provides Store access to its descendants via a
/// static [of] method.
class StoreProvider extends StatefulWidget {
  StoreProvider({
    @required this.store,
    @required this.child,
    this.disposeStore = false,
    Key key,
  }) : super(key: key);

  final ReduxStore store;
  final Widget child;
  final bool disposeStore;

  static ReduxStore of(BuildContext context) {
    final Type type = _type<_InheritedStoreProvider>();

    // ignore: deprecated_member_use
    Widget widget = context.inheritFromWidgetOfExactType(type);

    if (widget == null) {
      throw Exception('Couldn\'t find a StoreProvider of the correct type ($type).');
    } else {
      return (widget as _InheritedStoreProvider).store;
    }
  }

  @override
  _StoreProviderState createState() => _StoreProviderState();

  static Type _type<T>() => T;
}

class _StoreProviderState extends State<StoreProvider> {
  @override
  Widget build(BuildContext context) {
    return _InheritedStoreProvider(store: widget.store, child: widget.child);
  }

  @override
  void dispose() {
    if (widget.disposeStore) {
      widget.store.dispose();
    }

    super.dispose();
  }
}

/// The [InheritedWidget] used by [StoreProvider].
class _InheritedStoreProvider extends InheritedWidget {
  _InheritedStoreProvider({Key key, Widget child, this.store}) : super(key: key, child: child);

  final ReduxStore store;

  @override
  bool updateShouldNotify(_InheritedStoreProvider oldWidget) => oldWidget.store != store;
}
