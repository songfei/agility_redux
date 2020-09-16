import 'dart:async';

import 'package:agility_redux/agility_redux_inner.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'model_name_provider.dart';
import 'state_stack_map_provider.dart';
import 'store_provider.dart';

/// Accepts a [BuildContext] and ViewModel and builds a Widget in response. A
/// [DispatchFunction] is provided so widgets in the returned subtree can
/// dispatch new actions to the Store in response to UI events.
typedef ViewModelWidgetBuilder<V> = Widget Function(BuildContext context, DispatchFunction dispatcher, V viewModel);

/// Creates a new view model instance from the given state object. This method
/// should be used to narrow or filter the data present in [state] to the
/// minimum required by the [ViewModelWidgetBuilder] the converter will be used
/// with.
typedef ViewModelConverter<V> = V Function(ReduxState state);

/// Transforms a stream of state objects found via [StoreProvider] into a stream
/// of view models, and builds a [Widget] each time a distinctly new view model
/// is emitted by that stream.
///
/// This class is designed to minimize the number of times its subtree is built.
/// When a new state is emitted by Store.states, it's converted into a
/// view model using the provided [converter]. If (And only if) that new
/// instance is unequal to the previous one, the widget subtree is rebuilt using
/// [builder]. Any state changes emitted by the Store that don't impact the
/// view model used by a particular [ViewModelSubscriber] are ignored by it.
///
class ViewModelSubscriber<V> extends StatelessWidget {
  ViewModelSubscriber({
    @required this.converter,
    @required this.builder,
    Key key,
  }) : super(key: key);

  final ViewModelConverter<V> converter;
  final ViewModelWidgetBuilder<V> builder;

  @override
  Widget build(BuildContext context) {
    ReduxStore store = StoreProvider.of(context);
    String moduleName = ModelNameProvider.of(context);
    Map<String, int> stackMap = StateStackMapProvider.of(context);
    return _ViewModelStreamBuilder<V>(
      dispatcher: store.dispatch,
      stream: store.states,
      converter: converter,
      builder: builder,
      moduleName: moduleName,
      stackMap: stackMap,
    );
  }
}

/// Does the actual work for [ViewModelSubscriber].
class _ViewModelStreamBuilder<V> extends StatefulWidget {
  _ViewModelStreamBuilder({
    @required this.dispatcher,
    @required this.stream,
    @required this.converter,
    @required this.builder,
    this.moduleName,
    this.stackMap,
  });

  final DispatchFunction dispatcher;
  final BehaviorSubject<ReduxStateInner> stream;
  final ViewModelConverter<V> converter;
  final ViewModelWidgetBuilder<V> builder;
  final String moduleName;
  final Map<String, int> stackMap;

  @override
  _ViewModelStreamBuilderState createState() => _ViewModelStreamBuilderState<V>();
}

/// Subscribes to a stream of app state objects, converts each one into a view
/// model, and then uses it to rebuild its children.
class _ViewModelStreamBuilderState<V> extends State<_ViewModelStreamBuilder<V>> {
  V _latestViewModel;
  StreamSubscription<V> _subscription;

  void _subscribe() {
    _latestViewModel = widget.converter(ReduxState(
      state: widget.stream.value,
      moduleName: widget.moduleName,
      stackMap: widget.stackMap,
    ));
    _subscription = widget.stream
        .map<V>((s) => widget.converter(
              ReduxState(
                state: s,
                moduleName: widget.moduleName,
                stackMap: widget.stackMap,
              ),
            ))
        .distinct()
        .listen((viewModel) {
      setState(() => _latestViewModel = viewModel);
    });
  }

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  /// During stateful hot reload, the [_ViewModelStreamBuilder] widget is
  /// replaced, but this [State] object is not. It's important, therefore, to
  /// unsubscribe from the previous widget's stream and subscribe to the new
  /// one.
  @override
  void didUpdateWidget(_ViewModelStreamBuilder<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _subscription.cancel();
    _subscribe();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.dispatcher, _latestViewModel);
  }
}
