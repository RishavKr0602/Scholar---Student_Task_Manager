import 'package:flutter/services.dart';

/// Centralized, subtle haptic feedback so interactions feel tactile and
/// premium. Safe to call on every platform — no-ops where unsupported.
class AppHaptics {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void selection() => HapticFeedback.selectionClick();

  /// A short double-tap pattern used to celebrate completing a task.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.lightImpact();
  }
}
