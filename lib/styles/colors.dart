import 'package:flutter/material.dart';

Color primaryTextColor = Color(0XFF5F6368);
Color secondaryTextColor = Color(0XFFE93B2D);
Color tertiaryColor = Color(0XFFA7A7A7);
Color logoTintColor = Color(0XFFFCE3E0);
Color semiTransColor = Color.fromRGBO(117, 58, 136, 0.5);
Color shadowColor = Color(0xFFB7B7B7).withOpacity(.50);
Color navColor = Color(0XFFCC2B5E).withOpacity(.60);
Color lightBackgroundColor = Colors.white.withOpacity(.80);

Map<int, Color> secColor = {
  50: Color.fromRGBO(117, 58, 136, .1),
  100: Color.fromRGBO(117, 58, 136, .2),
  200: Color.fromRGBO(117, 58, 136, .3),
  300: Color.fromRGBO(117, 58, 136, .4),
  400: Color.fromRGBO(117, 58, 136, .5),
  500: Color.fromRGBO(117, 58, 136, .6),
  600: Color.fromRGBO(117, 58, 136, .7),
  700: Color.fromRGBO(117, 58, 136, .8),
  800: Color.fromRGBO(117, 58, 136, .9),
  900: Color.fromRGBO(117, 58, 136, 1),
};

MaterialColor secondColor = MaterialColor(0XFF753A88, secColor);

Map<int, Color> firColor = {
  50: Color.fromRGBO(204, 43, 94, .1),
  100: Color.fromRGBO(204, 43, 94, .2),
  200: Color.fromRGBO(204, 43, 94, .3),
  300: Color.fromRGBO(204, 43, 94, .4),
  400: Color.fromRGBO(204, 43, 94, .5),
  500: Color.fromRGBO(204, 43, 94, .6),
  600: Color.fromRGBO(204, 43, 94, .7),
  700: Color.fromRGBO(204, 43, 94, .8),
  800: Color.fromRGBO(204, 43, 94, .9),
  900: Color.fromRGBO(204, 43, 94, 1),
};
MaterialColor firstColor = MaterialColor(0XFFCC2B5E, firColor);

Map<int, Color> dark = {
  50: Color.fromRGBO(10, 14, 33, .1),
  100: Color.fromRGBO(10, 14, 33, .2),
  200: Color.fromRGBO(10, 14, 33, .3),
  300: Color.fromRGBO(10, 14, 33, .4),
  400: Color.fromRGBO(10, 14, 33, .5),
  500: Color.fromRGBO(10, 14, 33, .6),
  600: Color.fromRGBO(10, 14, 33, .7),
  700: Color.fromRGBO(10, 14, 33, .8),
  800: Color.fromRGBO(10, 14, 33, .9),
  900: Color.fromRGBO(10, 14, 33, 1),
};
MaterialColor darkColor = MaterialColor(0XFF0A0E21, dark);
