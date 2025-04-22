import 'package:flutter/material.dart';

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

class SlideTransitionAnimation extends PageRouteBuilder {
  final x = 0;
  final Widget page;

  SlideTransitionAnimation(this.page)
      : super(
            pageBuilder: (context, animation, anotherAnimation) => page,
            transitionDuration: const Duration(milliseconds: 2000),
            transitionsBuilder: (context, animation, anotherAnimation, child) {
              animation = CurvedAnimation(
                curve: Curves.fastLinearToSlowEaseIn,
                parent: animation,
              );
              return SlideTransition(
                position: Tween(
                        begin: const Offset(1.0, 0.0),
                        end: const Offset(0.0, 0.0))
                    .animate(animation),
                textDirection: TextDirection.rtl,
                child: page,
              );
            });
}
