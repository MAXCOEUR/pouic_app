import 'package:flutter/material.dart';

import 'vue/LoginVue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});


  ColorScheme lightColorScheme = const ColorScheme(
    primary: Color(0xFF3498DB),  // Darker shade of primary color (if needed)
    secondary: Color(0xFFE74C3C),// Darker shade of secondary color (if needed)
    surface: Color(0xFFF5F5F5),         // Background color
    background: Color(0xFFF5F5F5),      // Background color
    error: Color(0xFFB00020),           // Error color
    onPrimary: Color(0xFF333333),       // Text color on primary color
    onSecondary: Color(0xFFFFFFFF),     // Text color on secondary color
    onSurface: Color(0xFF333333),       // Text color on background color
    onBackground: Color(0xFF333333),    // Text color on background color
    onError: Color(0xFFFFFFFF),         // Text color on error color
    brightness: Brightness.light,       // Light mode
  );

  ColorScheme darkColorScheme = const ColorScheme(
    primary: Color(0xFF9B59B6),  // Darker shade of primary color (if needed)
    secondary: Color(0xFF2ECC71),// Darker shade of secondary color (if needed)
    surface: Color(0xFF1A1A1A),         // Background color
    background: Color(0xFF1A1A1A),      // Background color
    error: Color(0xFFCF6679),           // Error color
    onPrimary: Color(0xFFFFFFFF),       // Text color on primary color
    onSecondary: Color(0xFFFFFFFF),     // Text color on secondary color
    onSurface: Color(0xFFFFFFFF),       // Text color on background color
    onBackground: Color(0xFFFFFFFF),    // Text color on background color
    onError: Color(0xFF333333),         // Text color on error color
    brightness: Brightness.dark,        // Dark mode
  );


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light().copyWith(colorScheme: lightColorScheme),
      darkTheme: ThemeData.dark().copyWith(colorScheme: darkColorScheme),
      home: const LoginVue(),
    );
  }
}
