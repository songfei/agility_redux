import 'package:agility_redux_bloc/agility_redux_bloc.dart';
import 'package:flutter/material.dart';

import 'counter_bloc/counter_bloc.dart';

void main() {
  GlobalNavigator().addGlobalNavigator('page');
  GlobalNavigator().addGlobalNavigator('popupBox');

  BlocManager().registerBloc(CounterBloc());

  BlocManager().initStore();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          print('build ${constraints.maxWidth}');
          double padding = (constraints.maxWidth - 1000) / 2.0;
          print('padding: $padding');
          return Container(
            color: Colors.red,
            child: AppNavigator(
              initialPage: 'counter/counter_page',
              pageNavigatorName: 'page',
              popupBoxNavigatorName: 'popupBox',
              width: 600,
            ),
          );
        },
      ),
    );
  }
}
