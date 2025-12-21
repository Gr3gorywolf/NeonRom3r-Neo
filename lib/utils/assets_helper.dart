import 'package:flutter/material.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';

class AssetsHelper {
  static getImage(String name, {double size = 24, double? width}) {
    return Image.asset(
      "assets/images/$name.png",
      height: size,
      width: width ?? size,
    );
  }

  static Image getIcon(String name, {double size = 24, double? width = 24}) {
    final double finalWidth = width ?? size;
    final String? fallbackUrl =
        ConsolesHelper.getConsoleFromName(name)?.logoUrl;

    Widget errorIcon() => Icon(Icons.error, size: size);

    return Image.asset(
      "assets/icons/$name.png",
      height: size,
      width: finalWidth,
      errorBuilder: (_, __, ___) {
        if (fallbackUrl == null) return errorIcon();

        return Image.network(
          fallbackUrl,
          height: size,
          width: finalWidth,
          errorBuilder: (_, __, ___) => errorIcon(),
        );
      },
    );
  }
}
