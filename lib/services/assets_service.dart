import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yamata_launcher/services/console_service.dart';

class AssetsService {
  static getImage(String name, {double size = 24, double? width}) {
    var hasExtension = name.contains('.');
    return Image.asset(
      "assets/images/$name${hasExtension ? '' : '.png'}",
      height: size,
      width: width ?? size,
    );
  }

  static getSvgImage(String name, {double size = 24, double? width}) {
    return SvgPicture.asset("assets/svgs/$name.svg",
        semanticsLabel: 'Dart Logo', height: size, width: width ?? size);
  }

  static Image getConsoleIcon(String name,
      {double size = 24, double? width = 24}) {
    final double finalWidth = width ?? size;
    final String? fallbackUrl =
        ConsoleService.getConsoleFromName(name)?.logoUrl;

    Widget errorIcon() => Icon(Icons.error, size: size);

    return Image.asset(
      "assets/icons/consoles/${name.toUpperCase()}.png",
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
