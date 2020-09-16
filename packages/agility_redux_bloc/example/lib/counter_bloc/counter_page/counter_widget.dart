import 'package:agility_redux_bloc/agility_redux_bloc.dart';
import 'package:flutter/material.dart';

import '../counter_redux_bloc.dart';
import 'counter_view_model.dart';

class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: Center(
        child: ViewModelSubscriber<CounterViewModel>(
            converter: (state) => CounterViewModel.fromState(state),
            builder: (context, dispatcher, viewModel) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '${viewModel.number}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  FlatButton(
                    onPressed: () {
                      GlobalNavigator().navigatorEntry('page').push('counter/counter_page', holdBlocNames: ['counter']);
                    },
                    child: Text('push new page'),
                  ),
                ],
              );
            }),
      ),
      floatingActionButton: DispatchSubscriber(builder: (context, dispatcher) {
        return FloatingActionButton(
          onPressed: () {
            dispatcher(CounterAddAction());
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        );
      }), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
