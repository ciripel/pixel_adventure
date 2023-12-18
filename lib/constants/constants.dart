import 'package:flutter/material.dart';

abstract class Constants {
  //sizes
  static const double horizontalResolution = 500;
  static const double verticalResolution = 240;
  static const double controlsMargin = 20;
  static const double controlsSize = 64;
  static const double spaceBetweenButtons = 10;

  //text style
  static const hudTextStyle = TextStyle(
    fontSize: 10,
    fontFamily: 'PressStart2P',
    color: Color.fromRGBO(187, 170, 13, 1),
  );
}
