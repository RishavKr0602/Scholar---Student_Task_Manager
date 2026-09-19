import 'package:flutter/material.dart';

/// A smooth, premium page route: the incoming page fades while sliding up a
/// touch, and the outgoing page eases back slightly. Used app-wide so every
/// navigation feels consistent and polished.
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeSlidePageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 340),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.035),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Convenience helper: `context.pushSmooth(const SomeScreen())`.
extension SmoothNav on BuildContext {
  Future<T?> pushSmooth<T>(Widget page) {
    return Navigator.of(this).push<T>(FadeSlidePageRoute<T>(page: page));
  }
}
