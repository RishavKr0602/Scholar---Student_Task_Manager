import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color secondary = Color(0xFF06B6D4); // Cyan 500
  static const Color accent = Color(0xFF8B5CF6); // Violet 500

  // Neutral Backgrounds & Surfaces (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200

  // Neutral Backgrounds & Surfaces (Dark)
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155); // Slate 700

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Status & Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444); // Red 500
  static const Color priorityHighBg = Color(0xFFFEE2E2); // Red 100
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber 500
  static const Color priorityMediumBg = Color(0xFFFEF3C7); // Amber 100
  static const Color priorityLow = Color(0xFF10B981); // Emerald 500
  static const Color priorityLowBg = Color(0xFFD1FAE5); // Emerald 100

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Category Colors
  static const Color categoryAssignment = Color(0xFF6366F1); // Indigo
  static const Color categoryExam = Color(0xFFEC4899); // Pink
  static const Color categoryProject = Color(0xFF8B5CF6); // Purple
  static const Color categoryLab = Color(0xFF06B6D4); // Cyan
  static const Color categoryPersonal = Color(0xFF10B981); // Emerald
  static const Color categoryOther = Color(0xFF64748B); // Slate
}
