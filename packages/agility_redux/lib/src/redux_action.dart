import 'package:stack_trace/stack_trace.dart';

/// A Redux-style action. Apps change their overall state by dispatching actions
/// to the ReduxStore, where they are acted on by middleware, reducers, and
/// afterware in that order.
abstract class ReduxAction {
  // Dispatch action timestamp
  int timestamp;

  // Dispatch action call stack trace
  Trace currentTrace;
}

/// Private redux action, receives action only for specified modules.
abstract class ReduxPrivateAction extends ReduxAction {
  @override
  int timestamp;

  @override
  Trace currentTrace;

  String get packageName {
    return '';
  }
}

/// An action that middleware and afterware methods can return in order to
/// cancel (or "swallow") an action already dispatched to their ReduxStore. Because
/// rebloc uses a stream to track Actions through the
/// dispatch->middleware->reducer->afterware pipeline, a middleware/afterware
/// method should return something. By returning an instance of this class
/// (which is private to this library), a developer can in effect cancel actions
/// via middleware.
class CancelledAction extends ReduxAction {
  CancelledAction();
}
