import 'dart:ui';

import 'package:agility_redux/agility_redux.dart';
import 'package:agility_redux_widget/agility_redux_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bloc_route_settings.dart';

typedef BlocPopupBoxBuilder = BlocPopupBoxRoute Function(BlocRouteSettings settings);

/// Popup box route of business module
abstract class BlocPopupBoxRoute<T> extends ModalRoute<T> {
  BlocPopupBoxRoute({BlocRouteSettings settings}) : super(settings: settings);

  String get name {
    return settings.name;
  }

  Map<String, dynamic> get arguments {
    return settings.arguments;
  }

  ReduxStore get store {
    BlocRouteSettings blocSettings = settings;
    return blocSettings.store;
  }

  @override
  Color get barrierColor => Color.fromRGBO(0, 0, 0, 0.1);

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => '';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2,
      child: ModelNameProvider(
        blocName: name.split('/')[0] ?? '',
        child: buildWithAnimation(context, animation, secondaryAnimation),
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  Widget buildWithAnimation(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return build(context);
  }
}

enum PopupPosition {
  right,
  bottom,
}

class _BlocSidePopupBoxSuspendedCurve extends ParametricCurve<double> {
  /// Creates a suspended curve.
  const _BlocSidePopupBoxSuspendedCurve(
    this.startingPoint, {
    this.curve = Curves.easeOutCubic,
  })  : assert(startingPoint != null),
        assert(curve != null);

  /// The progress value at which [curve] should begin.
  ///
  /// This defaults to [Curves.easeOutCubic].
  final double startingPoint;

  /// The curve to use when [startingPoint] is reached.
  final Curve curve;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    assert(startingPoint >= 0.0 && startingPoint <= 1.0);

    if (t < startingPoint) {
      return t;
    }

    if (t == 1.0) {
      return t;
    }

    final double curveProgress = (t - startingPoint) / (1 - startingPoint);
    final double transformed = curve.transform(curveProgress);
    return lerpDouble(startingPoint, 1, transformed);
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($startingPoint, $curve)';
  }
}

class _BlocSidePopupBox<T> extends StatefulWidget {
  const _BlocSidePopupBox({
    Key key,
    this.route,
    this.isScrollControlled = false,
    this.enableDrag = true,
    this.popupPosition = PopupPosition.bottom,
  })  : assert(isScrollControlled != null),
        assert(enableDrag != null),
        super(key: key);

  final BlocSidePopupBoxRoute<T> route;
  final bool isScrollControlled;
  final bool enableDrag;
  final PopupPosition popupPosition;

  @override
  _BlocSidePopupBoxState<T> createState() => _BlocSidePopupBoxState<T>();
}

class _BlocBottomPopupBoxLayout extends SingleChildLayoutDelegate {
  _BlocBottomPopupBoxLayout(this.progress, this.isScrollControlled);

  final double progress;
  final bool isScrollControlled;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: isScrollControlled ? constraints.maxHeight : constraints.maxHeight * 9.0 / 16.0,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_BlocBottomPopupBoxLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _BlocRightPopupBoxLayout extends SingleChildLayoutDelegate {
  _BlocRightPopupBoxLayout(this.progress, this.isScrollControlled);

  final double progress;
  final bool isScrollControlled;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: 0.0,
      maxWidth: isScrollControlled ? constraints.maxWidth : constraints.maxWidth * 9.0 / 16.0,
      minHeight: constraints.maxHeight,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(size.width - childSize.width * progress, 0.0);
  }

  @override
  bool shouldRelayout(_BlocRightPopupBoxLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _BlocSidePopupBoxState<T> extends State<_BlocSidePopupBox<T>> {
  ParametricCurve<double> animationCurve = decelerateEasing;

  void handleDragStart(DragStartDetails details) {
    animationCurve = Curves.linear;
  }

  void handleDragEnd(DragEndDetails details, {bool isClosing}) {
    animationCurve = _BlocSidePopupBoxSuspendedCurve(
      widget.route.animation.value,
      curve: decelerateEasing,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: widget.route.animation,
      child: BottomSheet(
        animationController: widget.route._animationController,
        onClosing: () {
          if (widget.route.isCurrent) {
            Navigator.pop(context);
          }
        },
        backgroundColor: Colors.transparent,
        builder: widget.route.build,
        enableDrag: widget.enableDrag,
        onDragStart: handleDragStart,
        onDragEnd: handleDragEnd,
      ),
      builder: (BuildContext context, Widget child) {
        final double animationValue = animationCurve.transform(mediaQuery.accessibleNavigation ? 1.0 : widget.route.animation.value);

        SingleChildLayoutDelegate layoutDelegate;
        if (widget.popupPosition == PopupPosition.bottom) {
          layoutDelegate = _BlocBottomPopupBoxLayout(animationValue, widget.isScrollControlled);
        } else if (widget.popupPosition == PopupPosition.right) {
          layoutDelegate = _BlocRightPopupBoxLayout(animationValue, widget.isScrollControlled);
        }

        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          child: CustomSingleChildLayout(
            delegate: layoutDelegate,
            child: child,
          ),
        );
      },
    );
  }
}

class BlocSidePopupBoxRoute<T> extends BlocPopupBoxRoute<T> {
  BlocSidePopupBoxRoute({RouteSettings settings}) : super(settings: settings);

  PopupPosition get popupPosition => PopupPosition.bottom;

  bool get enableDrag => true;

  bool get isScrollControlled => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);

  @override
  Duration get reverseTransitionDuration => Duration(milliseconds: 200);

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildWithAnimation(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Builder(
        builder: (BuildContext context) {
          return _BlocSidePopupBox<T>(
            route: this,
            isScrollControlled: isScrollControlled,
            enableDrag: enableDrag,
            popupPosition: popupPosition,
          );
        },
      ),
    );
    return bottomSheet;
  }
}
