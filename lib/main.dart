import 'package:discution_app/HomeTmp.dart';
import 'package:flutter/material.dart';


void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  ColorScheme lightColorScheme = const ColorScheme(
    primary: Color(0xFF2196F3),    // Bleu primaire
    secondary: Color(0xFF64B5F6),  // Bleu clair
    surface: Color(0xFFC0C0C0),   // Blanc (arrière-plan)
    background: Color(0xFFFFFFFF),// Blanc (arrière-plan)
    error: Color(0xFFC62828),     // Rouge (erreur)
    onPrimary: Color(0xFFFFFFFF), // Texte blanc sur fond bleu primaire
    onSecondary: Color(0xFF333333),// Texte gris foncé sur fond bleu clair
    onSurface: Color(0xFF333333), // Texte gris foncé sur fond blanc
    onBackground: Color(0xFF000000),// Texte noir sur fond blanc
    onError: Color(0xFFFFFFFF),    // Texte blanc sur fond rouge (erreur)
    brightness: Brightness.light,  // Mode clair
  );

  ColorScheme darkColorScheme = const ColorScheme(
    primary: Color(0xFF2196F3),    // Bleu primaire
    secondary: Color(0xFF64B5F6),  // Bleu clair
    surface: Color(0xFF1F1F1F),   // Gris foncé (arrière-plan)
    background: Color(0xFF121212),// Gris foncé (arrière-plan)
    error: Color(0xFFC62828),     // Rouge (erreur)
    onPrimary: Color(0xFFFFFFFF), // Texte blanc sur fond bleu primaire
    onSecondary: Color(0xFF333333),// Texte gris foncé sur fond bleu clair
    onSurface: Color(0xFFFFFFFF), // Texte blanc sur fond gris foncé
    onBackground: Color(0xFFFFFFFF),// Texte blanc sur fond gris foncé
    onError: Color(0xFF333333),    // Texte gris foncé sur fond rouge (erreur)
    brightness: Brightness.dark,   // Mode sombre
  );



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light().copyWith(colorScheme: lightColorScheme),
      darkTheme: ThemeData.dark().copyWith(colorScheme: darkColorScheme),
      home: HomeTmp(),
    );
  }
}
