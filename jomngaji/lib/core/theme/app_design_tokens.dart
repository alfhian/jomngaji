import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Deep & Professional)
  static const primary = Color(0xFF0F172A); // Slate 900
  static const primaryLight = Color(0xFF1E293B); // Slate 800
  static const accent = Color(0xFF10B981); // Emerald 500 (Fresh Green)
  static const accentLight = Color(0xFFD1FAE5); // Emerald 100
  
  // Secondary / Action Colors
  static const secondary = Color(0xFF6366F1); // Indigo 500
  static const gold = Color(0xFFF59E0B); // Amber 500
  
  // Neutral Colors
  static const surface = Colors.white;
  static const scaffold = Color(0xFFF8FAFC); // Slate 50
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B); // Slate 500
  static const textPlaceholder = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0); // Slate 200
}

class AppGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  static const accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
  );

  static const glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white24, Colors.white10],
  );
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 28.0;
  static const full = 999.0;
}

class AppShadows {
  static final soft = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static final medium = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
