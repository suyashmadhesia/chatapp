import 'package:flutter/material.dart';

class ScreenSize {
  final double height;
  final double width;
  final BuildContext context;

  ScreenSize({this.height, this.width, this.context});

  double dividingHeight() {
    double hPixels = height / 1000;
    return hPixels;
  }

  double dividingWidth() {
    double hPixels = width / 100;
    return hPixels;
  }

  double horizontal(double width) {
    return MediaQuery.of(context).size.width * width / 100;
  }

  double vertical(double height) {
    return MediaQuery.of(context).size.height * height / 100;
  }
}
