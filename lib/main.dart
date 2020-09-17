import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photonix_app/pages/splash_screen_page.dart';
import 'package:photonix_app/styles/colors.dart';

final ThemeData lightTheme = ThemeData(
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    accentColor: firstColor,
    primaryColorDark: darkColor,
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.white, foregroundColor: secondColor),
    bottomAppBarColor: Colors.white,
    appBarTheme: AppBarTheme(color: Colors.white),
    brightness: Brightness.light);

final ThemeData darkTheme = ThemeData(
    canvasColor: darkColor,
    scaffoldBackgroundColor: darkColor,
    accentColor: Colors.white,
    primaryColorDark: Colors.white,
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: Color(0xFF111328)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4C4F5E), foregroundColor: Colors.white),
    iconTheme: IconThemeData(color: Colors.white),
    bottomAppBarColor: Color(0xFF4C4F5E),
    appBarTheme: AppBarTheme(color: darkColor),
    brightness: Brightness.dark);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(persistenceEnabled: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photonix',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: SplashScreen(),
    );
  }
}
