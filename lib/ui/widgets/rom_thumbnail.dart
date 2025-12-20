import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/ui/widgets/console_card.dart';
import 'package:neonrom3r/utils/animation_helper.dart';
import 'package:neonrom3r/utils/assets_helper.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';
import 'package:neonrom3r/utils/files_system_helper.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RomThumbnail extends StatelessWidget {
  RomInfo info;
  double height;
  double width;
  RomThumbnail(this.info, {this.height = 50, this.width = 50});

  File? get catchedImage {
    var path = "${FileSystemHelper.portraitsPath}/${this.info.name}.png";
    if (File(path).existsSync()) {
      return File(path);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      info?.portrait ?? "",
      errorBuilder: (context, obj, trace) {
        if (catchedImage != null) {
          return Image.file(
            catchedImage!,
            height: this.height,
            width: this.width,
            fit: BoxFit.cover,
          );
        }
        return AssetsHelper.getIcon(info.console, size: width);
      },
      loadingBuilder: (child, widget, progress) {
        if (progress == null) return widget;
        return Skeletonizer.zone(
          enabled: true,
          child: Bone(height: double.infinity, width: double.infinity),
        );
      },
      height: this.height,
      width: this.width,
      fit: BoxFit.cover,
    );
  }
}
