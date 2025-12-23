import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/ui/widgets/console_card.dart';
import 'package:neonrom3r/utils/animation_helper.dart';
import 'package:neonrom3r/services/assets_service.dart';
import 'package:neonrom3r/services/console_service.dart';
import 'package:neonrom3r/services/files_system_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RomThumbnail extends StatefulWidget {
  RomInfo info;
  double height;
  double width;
  Duration? timeout;
  RomThumbnail(this.info, {this.height = 50, this.width = 50, this.timeout});

  @override
  State<RomThumbnail> createState() => _RomThumbnailState();
}

class _RomThumbnailState extends State<RomThumbnail> {
  var timeoutEnded = false;
  File? getCatchedImage() {
    var path =
        "${FileSystemService.portraitsPath}/${this.widget.info.slug}.png";
    if (File(path).existsSync()) {
      return File(path);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    if (widget.timeout != null) {
      Future.delayed(widget.timeout!, () {
        if (this.mounted) {
          setState(() {
            timeoutEnded = true;
          });
        }
      });
    } else {
      timeoutEnded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!timeoutEnded) {
      return Skeletonizer.zone(
        enabled: true,
        child: Bone(height: double.infinity, width: double.infinity),
      );
    }
    if (Uri.tryParse(widget.info.portrait ?? "") == null) {
      return AssetsService.getIcon(
        widget.info.console,
        size: widget.width,
      );
    }
    return Image.network(
      widget.info?.portrait ?? "",
      errorBuilder: (context, obj, trace) {
        var cachedImg = getCatchedImage();
        if (cachedImg != null) {
          return Image.file(
            cachedImg,
            height: this.widget.height,
            width: this.widget.width,
            fit: BoxFit.cover,
          );
        }
        return AssetsService.getIcon(widget.info.console, size: widget.width);
      },
      loadingBuilder: (child, widget, progress) {
        if (progress == null) return widget;
        return Skeletonizer.zone(
          enabled: true,
          child: Bone(height: double.infinity, width: double.infinity),
        );
      },
      height: this.widget.height,
      width: this.widget.width,
      fit: BoxFit.cover,
    );
  }
}
