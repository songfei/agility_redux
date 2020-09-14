import 'redux_action.dart';
import 'redux_bloc.dart';
import 'redux_state.dart';
import 'redux_state_inner.dart';
import 'redux_store.dart';

class GlobalStore {
  factory GlobalStore() {
    return _instance;
  }

  GlobalStore._internal();

  static GlobalStore _instance = GlobalStore._internal();

  ReduxStore store;

  void initStore(
    List<ReduxBloc> blocs, {
    bool isDebug = false,
  }) {
    store = ReduxStore(
      blocs: blocs,
      isDebug: isDebug,
    );
  }

  T publicState<T>(String name) {
    ReduxStateInner innerState = store.states.value;
    return innerState.byName(name);
  }

  T privateState<T>(String name) {
    ReduxStateInner innerState = store.states.value;
    return innerState.byName('_$name');
  }

  void dispatch(ReduxAction action) {
    store.dispatch(action);
  }

  ReduxState reduxState(String name) {
    return ReduxState(moduleName: name, state: store.states.value);
  }

  void pushState(String name) {
    store.pushState(name);
  }

  void popState(String name) {
    store.popState(name);
  }

  // for debug
  void clearDebugActionList() {
    store.clearDebugActionList();
  }

  // for debug
  ReduxAction get lastDispatchAction {
    return store.debugActionList.last;
  }

  // for debug
  List<ReduxAction> get actionList {
    return store.debugActionList;
  }

  void reset() {
    _instance = GlobalStore._internal();
  }
}
