import 'dart:io';

import 'package:Pouic/HomeTmp.dart';
import 'package:Pouic/fireBase/fireBase_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

late final FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();

void main() async {

  if(!kIsWeb && !Platform.isWindows){
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    // Initialiser les notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('mipmap/ic_launcher'); // Remplacez 'app_icon' par le nom de votre icône de l'application
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin?.initialize(initializationSettings);
  }


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  ColorScheme lightColorScheme = const ColorScheme(
    primary: Color(0xFFb50c8b),    // Couleur principale
    secondary: Color(0xFF550077),  // Couleur secondaire
    surface: Color(0xFFC0C0C0),   // Blanc (arrière-plan)
    background: Color(0xFFFFFFFF),// Blanc (arrière-plan)
    error: Color(0xFFC62828),     // Rouge (erreur)
    onPrimary: Color(0xFFFFFFFF), // Texte blanc sur fond de couleur principale
    onSecondary: Color(0xFFFFFFFF),// Texte gris foncé sur fond de couleur secondaire
    onSurface: Color(0xFF333333), // Texte gris foncé sur fond blanc
    onBackground: Color(0xFF000000),// Texte noir sur fond blanc
    onError: Color(0xFFFFFFFF),    // Texte blanc sur fond rouge (erreur)
    brightness: Brightness.light,  // Mode clair
  );

  ColorScheme darkColorScheme = const ColorScheme(
    primary: Color(0xFFb50c8b),    // Couleur principale
    secondary: Color(0xFF550077),  // Couleur secondaire
    surface: Color(0xFF1F1F1F),   // Gris foncé (arrière-plan)
    background: Color(0xFF121212),// Gris foncé (arrière-plan)
    error: Color(0xFFC62828),     // Rouge (erreur)
    onPrimary: Color(0xFFFFFFFF), // Texte blanc sur fond de couleur principale
    onSecondary: Color(0xFFFFFFFF),// Texte gris foncé sur fond de couleur secondaire
    onSurface: Color(0xFFFFFFFF), // Texte blanc sur fond de couleur surface
    onBackground: Color(0xFFFFFFFF),// Texte blanc sur fond de couleur background
    onError: Color(0xFF333333),    // Texte gris foncé sur fond de couleur erreur
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
