import 'package:flutter/material.dart';

class AssetsHelper {
  static getImage(String name, {double size = 24}) {
    return Image.asset(
      "assets/images/$name.png",
      height: size,
      width: size,
    );
  }

    static getIcon(String name, {double size = 24}) {
    return Image.asset(
      "assets/icons/$name.png",
      height: size,
      width: size,
    );
  }
}
