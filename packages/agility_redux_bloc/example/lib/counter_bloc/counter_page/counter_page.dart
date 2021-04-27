import 'package:agility_redux_bloc/agility_redux_bloc.dart';
import 'package:flutter/material.dart';

import 'counter_widget.dart';

class CounterPage extends BlocPageRoute {
  CounterPage({
    BlocRouteSettings settings,
  }) : super(settings: settings);

  @override
  void init() {
    super.init();
  }

  @override
  void appear() {
    super.appear();
  }

  @override
  void disappear() {
    super.disappear();
  }

  @override
  Widget build(BuildContext context) {
    return AppNavigatorContainer(
      child: CounterWidget(),
      background: Column(
        children: [
          Container(
            height: 56.0,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
