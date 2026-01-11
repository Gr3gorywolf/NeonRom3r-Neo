import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/ui/widgets/console_card.dart';
import 'package:yamata_launcher/utils/animation_helper.dart';
import 'package:yamata_launcher/services/assets_service.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RomThumbnail extends StatefulWidget {
  RomInfo info;
  double height;
  double width;
  String? customUrl;
  Duration? timeout;
  RomThumbnail(this.info,
      {this.height = 50, this.width = 50, this.timeout, this.customUrl});

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
    var url = widget.customUrl ?? widget.info.portrait;
    if (!timeoutEnded) {
      return Skeletonizer.zone(
        enabled: true,
        child: Bone(height: double.infinity, width: double.infinity),
      );
    }
    if (Uri.tryParse(widget.info.portrait ?? "") == null) {
      return AssetsService.getConsoleIcon(
        widget.info.console,
        size: widget.width,
      );
    }
    var cachedImg = getCatchedImage();
    if (cachedImg != null) {
      return Image.file(
        cachedImg,
        height: this.widget.height,
        width: this.widget.width,
        cacheWidth: this.widget.width.toInt() * 4,
        cacheHeight: this.widget.height.toInt() * 4,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url ?? "",
      errorBuilder: (context, obj, trace) {
        return AssetsService.getConsoleIcon(widget.info.console,
            size: widget.width);
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
      cacheWidth: this.widget.width.toInt() * 4,
      cacheHeight: this.widget.height.toInt() * 4,
      fit: BoxFit.cover,
    );
  }
}
