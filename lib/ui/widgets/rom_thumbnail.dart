import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/ui/widgets/console_tile.dart';
import 'package:neonrom3r/utils/animation_helper.dart';
import 'package:neonrom3r/utils/assets_helper.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';
import 'package:neonrom3r/utils/files_system_helper.dart';

class RomThumbnail extends StatelessWidget {
  RomInfo info;
  double height;
  double width;
  RomThumbnail(this.info, {this.height = 50, this.width = 50});

  File get catchedImage {
    var path = "${FileSystemHelper.portraitsPath}/${this.info.name}.png";
    if (File(path).existsSync()) {
      return File(path);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return catchedImage == null
        ? Image.network(
            info.portrait,
            errorBuilder: (context, obj, trace) {
              return AssetsHelper.getIcon(
                  ConsolesHelper.getConsoleFromName(info.console).slug,
                  size: width);
            },
            loadingBuilder: (child, widget, progress) {
              if (progress == null) return widget;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              );
            },
            height: this.height,
            width: this.width,
            fit: BoxFit.cover,
          )
        : Image.file(
            catchedImage,
            height: this.height,
            width: this.width,
            fit: BoxFit.cover,
          );
  }
}
