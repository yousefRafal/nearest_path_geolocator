import 'package:flutter/material.dart';

class ScaleTransitionScreen extends PageRouteBuilder {
  final Widget page;

  ScaleTransitionScreen(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: const Duration(milliseconds: 1000),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
                curve: Curves.fastLinearToSlowEaseIn,
                parent: animation,
                reverseCurve: Curves.fastOutSlowIn);
            return ScaleTransition(
              alignment: Alignment.centerLeft,
              scale: animation,
              child: child,
            );
          },
        );
}

class ScaleTransitionScreen2 extends PageRouteBuilder {
  final Widget page;

  ScaleTransitionScreen2(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: const Duration(milliseconds: 1000),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
                curve: Curves.fastLinearToSlowEaseIn,
                parent: animation,
                reverseCurve: Curves.fastOutSlowIn);
            return ScaleTransition(
              alignment: Alignment.center,
              scale: animation,
              child: child,
            );
          },
        );
}

class SlideRoute extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;
  final Offset? startOffset;
  final Offset? endOffset;
  SlideRoute({
    required this.builder,
    bool fullscreenDialog = false,
    this.startOffset,
    this.endOffset,
  }) : super(
          fullscreenDialog: fullscreenDialog,
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (a, b, c) => builder(a),
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: startOffset ?? const Offset(0, 1),
        end: endOffset ?? Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;
  final RouteType routeType;
  final Alignment? scaleAlignment;
  final Offset? slideBeginOffset;
  final Curve curve;
  final Curve reverseCurve;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  CustomPageRoute({
    required this.child,
    this.routeType = RouteType.slide,
    this.scaleAlignment,
    this.slideBeginOffset,
    this.curve = Curves.fastOutSlowIn,
    this.reverseCurve = Curves.fastOutSlowIn,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    animation = CurvedAnimation(
      parent: animation,
      curve: curve,
      reverseCurve: reverseCurve,
    );

    switch (routeType) {
      case RouteType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: slideBeginOffset ?? const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      case RouteType.scale:
        return ScaleTransition(
          alignment: scaleAlignment ?? Alignment.center,
          scale: animation,
          child: child,
        );
      case RouteType.slideAndScale:
        return SlideTransition(
          position: Tween<Offset>(
            begin: slideBeginOffset ?? const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: ScaleTransition(
            alignment: scaleAlignment ?? Alignment.center,
            scale: animation,
            child: child,
          ),
        );
      case RouteType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
    }
  }
}

enum RouteType {
  slide,
  scale,
  slideAndScale,
  fade,
}
