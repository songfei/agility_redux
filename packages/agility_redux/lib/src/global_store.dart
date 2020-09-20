import 'redux_action.dart';
import 'redux_bloc.dart';
import 'redux_state.dart';
import 'redux_state_inner.dart';
import 'redux_store.dart';

/// Global singleton of ReduxStore
class GlobalStore {
  factory GlobalStore() {
    return _instance;
  }

  GlobalStore._internal();

  static GlobalStore _instance = GlobalStore._internal();

  bool _isDebug = false;
  ReduxStore store;

  /// Initialize ReduxStore
  void initStore(
    List<ReduxBloc> blocs, {
    bool isDebug = false,
  }) {
    _isDebug = isDebug;
    store = ReduxStore(
      blocs: blocs,
      isDebug: isDebug,
    );
  }

  /// Send application initialize action
  void sendAppInitAction(ReduxAction action) {
    store.dispatch(action);
  }

  /// Put a copy of the current state into the stack
  void pushState(String name) {
    store.pushState(name);
  }

  /// Pop the state at the top of the stack
  void popState(String name) {
    store.popState(name);
  }

  /// Gets the index of the current state of each module in the stack
  Map<String, int> get stackMap {
    ReduxStateInner innerState = store.states.value;
    return innerState.stackMap;
  }

  /// For Debug
  /// Get the public state of the module
  T publicState<T>(
    String name, {
    Map<String, int> stackMap,
  }) {
    if (_isDebug) {
      ReduxStateInner innerState = store.states.value;
      return innerState.byName(
        name,
        stackMap: stackMap,
      );
    }
    return null;
  }

  /// For Debug
  /// Get the private state of the module
  T privateState<T>(
    String name, {
    Map<String, int> stackMap,
  }) {
    if (_isDebug) {
      ReduxStateInner innerState = store.states.value;
      return innerState.byName(
        '_$name',
        stackMap: stackMap,
      );
    }
    return null;
  }

  /// For Debug
  /// Get the ReduxState object of the module
  ReduxState reduxState(String name) {
    if (_isDebug) {
      return ReduxState(
        moduleName: name,
        state: store.states.value,
      );
    }
    return null;
  }

  /// For Debug
  /// Dispatch action
  void dispatch(ReduxAction action) {
    if (_isDebug) {
      store.dispatch(action);
    }
  }

  /// For Debug
  /// Empty debug action list
  void clearDebugActionList() {
    store.clearDebugActionList();
  }

  /// For Debug
  /// Get the last one in the action list
  ReduxAction get lastDispatchAction {
    return store.debugActionList.last;
  }

  /// For Debug
  /// Get the entire action list
  List<ReduxAction> get actionList {
    return store.debugActionList;
  }

  /// Reset singleton
  void reset() {
    if (_isDebug) {
      _instance = GlobalStore._internal();
    }
  }
}
