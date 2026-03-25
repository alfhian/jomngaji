import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF42C88A),
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),
    fontFamily: 'Poppins',
  );
}
