/// ViewModel must be override == function
class ReduxViewModel {
  @override
  bool operator ==(Object other) => identical(this, other) || other is ReduxViewModel && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
