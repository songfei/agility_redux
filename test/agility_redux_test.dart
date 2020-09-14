import 'dart:async';

import 'package:agility_redux/agility_redux.dart';
import 'package:test/test.dart';

Future<void> wait() async {
  return Future.delayed(Duration(), () => 1);
}

class AddAAction extends ReduxAction {}

class AddBAction extends ReduxAction {}

class UpdateAAction extends ReduxAction {
  int a;
}

class UpdateBAction extends ReduxPrivateAction {
  @override
  String get packageName => 'test';

  int b;
}

class PublicState with ReduxStateItem<PublicState> {
  PublicState({
    this.a,
  });

  final int a;

  PublicState copyWith({
    int a,
  }) {
    return PublicState(
      a: a ?? this.a,
    );
  }

  @override
  PublicState clone() {
    return PublicState(a: a);
  }

  @override
  String toString() {
    return 'PublicState{a: $a} $hashCode';
  }
}

class PrivateState with ReduxStateItem<PrivateState> {
  PrivateState({
    this.b,
  });

  final int b;

  PrivateState copyWith({
    int b,
  }) {
    return PrivateState(
      b: b ?? this.b,
    );
  }

  @override
  PrivateState clone() {
    return PrivateState(b: b);
  }

  @override
  String toString() {
    return 'PrivateState{b: $b}';
  }
}

class TestReduxBloc extends SimpleReduxBloc<PublicState, PrivateState> {
  @override
  void initBloc() {}

  @override
  PrivateState get initialPrivateState => PrivateState();

  @override
  PublicState get initialState => PublicState();

  @override
  String get moduleName => 'test';

  @override
  PublicState reducer(ReduxAction action, PublicState state, PrivateState privateState) {
    PublicState newStatus = state;

    if (action is UpdateAAction) {
      newStatus = newStatus.copyWith(
        a: action.a,
      );
    }

    print('new state: $newStatus');
    return newStatus;
  }

  @override
  PrivateState privateReducer(ReduxAction action, PublicState state, PrivateState privateState) {
    PrivateState newState = privateState;

    if (action is UpdateBAction) {
      newState = newState.copyWith(
        b: action.b,
      );
    }

    return newState;
  }

  @override
  FutureOr<ReduxAction> middleware(DispatchFunction dispatcher, ReduxState state, ReduxAction action) {
    if (action is AddAAction) {
      () async {
        PublicState publicState = state.publicState<PublicState>();

        dispatcher(UpdateAAction()..a = publicState.a + 1);
      }();
    }
    //
    else if (action is AddBAction) {
      () async {
        PrivateState privateState = state.privateState<PrivateState>();

        dispatcher(UpdateBAction()..b = privateState.b + 1);
      }();
    }
    return action;
  }
}

void main() {
  setUp(() {
    GlobalStore().reset();
    GlobalStore().initStore([TestReduxBloc()], isDebug: true);
  });

  tearDown(() {});

  test('reducer', () async {
    GlobalStore().dispatch(UpdateAAction()..a = 100);
    await wait();
    PublicState state = GlobalStore().publicState<PublicState>('test');
    expect(state.a, 100);

    GlobalStore().dispatch(AddAAction());
    await wait();
    state = GlobalStore().publicState<PublicState>('test');
    expect(state.a, 101);
  });

  test('push/pop', () async {
    GlobalStore().dispatch(UpdateAAction()..a = 100);
    await wait();
    PublicState state = GlobalStore().publicState<PublicState>('test');
    expect(state.a, 100);

    print(GlobalStore().store);

    GlobalStore().pushState('test');
    state = GlobalStore().publicState<PublicState>('test');
    expect(state.a, 100);

    print(GlobalStore().store);

    GlobalStore().dispatch(UpdateAAction()..a = 200);
    await wait();
    state = GlobalStore().publicState<PublicState>('test');
    expect(state.a, 200);
    print(GlobalStore().store);

    GlobalStore().popState('test');
    print(GlobalStore().store);
    state = GlobalStore().publicState<PublicState>('test');
    expect(state.a, 100);
  });
}
