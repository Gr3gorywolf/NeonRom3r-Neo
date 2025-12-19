import 'package:flutter/material.dart';

class AssetsHelper {
  static getImage(String name, {double size = 24, double? width}) {
    return Image.asset(
      "assets/images/$name.png",
      height: size,
      width: width ?? size,
    );
  }

  static Image getIcon(String name, {double size = 24}) {
    return Image.asset(
      "assets/icons/$name.png",
      height: size,
      width: size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.error,
          size: size,
        );
      },
    );
  }
}
