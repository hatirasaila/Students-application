import 'package:flutter/material.dart';

// Light mode colors
const kPrimaryColor = Color.fromARGB(255, 33, 55, 127);
const kSecondaryColor = Color(0xff2BBDEE);
const kBackgroundColor = Color(0xffF9FAFF);

// Dark mode colors
const kDarkBackgroundColor = Color(0xff031956);
const kDarkBackgroundColor2 = Color(0xff344FA1);
const kDarkPrimaryColor = Color.fromARGB(255, 255, 255, 255);

class PrimaryColor extends MaterialStateColor {
  const PrimaryColor() : super(_defaultColor);

  static const int _defaultColor = 0xff0E1F55;
  static const int _pressedColor = 0xff0E1F55;

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return const Color(_pressedColor);
    }
    return const Color(_defaultColor);
  }
}
