import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yamata_launcher/models/aria2c.dart';
import 'package:yamata_launcher/models/download_source_rom.dart';
import 'package:yamata_launcher/providers/download_provider.dart';
import 'package:yamata_launcher/utils/string_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:yamata_launcher/services/rom_service.dart';
import 'package:provider/provider.dart';
import 'package:yamata_launcher/utils/system_helpers.dart';

import 'aria2c/aria2c_download_manager.dart';

class DownloadService {
  Future<Map<String, String>> fetchDownloadHeaders(url) async {
    var client = new http.Client();
    try {
      var res = await client.head(url);
      return res.headers;
    } catch (err) {
      return new Map<String, String>();
    }
  }

  String? _getFileNameFromHeaders(Map<String, String> headers) {
    if (headers.keys.contains('content-disposition')) {
      var fileNameArray = headers['content-disposition']!.split('filename="');
      if (fileNameArray.length > 0) {
        fileNameArray = fileNameArray[1].split('";');
        return fileNameArray[0];
      }
    }
    return null;
  }

  downloadRom(
      BuildContext context, RomInfo rom, DownloadSourceRom sourceRom) async {
    var downloadsPath = FileSystemService.downloadsPath;
    if (!await Directory(downloadsPath).exists()) {
      await Directory(downloadsPath).create();
    }
    final handle = await Aria2DownloadManager.startDownload(
      rom: rom,
      source: sourceRom,
      aria2cPath: FileSystemService.aria2cPath,
    );
    Provider.of<DownloadProvider>(context, listen: false)
        .addRomDownloadToQueue(rom, sourceRom, handle);
  }

  void catchRomPortrait(RomInfo romInfo) async {
    var portraitName = '${FileSystemService.portraitsPath}/${romInfo.slug}.png';
    var portraitUrl = romInfo.portrait ?? '';
    if (!File(portraitName).existsSync() && portraitUrl.isNotEmpty) {
      http.get(Uri.parse(romInfo.portrait ?? '')).then((response) {
        new File(portraitName).writeAsBytes(response.bodyBytes);
      });
    }
  }
}
