import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/providers/library_provider.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/native/intents_android_interface.dart';
import 'package:yamata_launcher/ui/pages/rom_settings_dialog/rom_settings_dialog.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

enum RomLibraryActionSize { small, medium, large }

class RomLibraryActions extends StatelessWidget {
  final RomInfo rom;
  RomLibraryActionSize? size = RomLibraryActionSize.medium;

  RomLibraryActions({super.key, required this.rom, this.size});
  @override
  Widget build(BuildContext context) {
    var libraryProvider = Provider.of<LibraryProvider>(context);
    var _libraryDetails = libraryProvider.getLibraryItem(rom.slug);
    var isFavorite = (_libraryDetails?.isFavorite ?? false) == true;
    double? minimumSize = 35;
    double? iconSize = 22;
    double spacing = 8;
    double contentWidth = 35;

    if (size == RomLibraryActionSize.small) {
      minimumSize = 30;
      iconSize = 18;
      contentWidth = 30;
    } else if (size == RomLibraryActionSize.large) {
      minimumSize = 40;
      iconSize = 26;
      contentWidth = 40;
    }

    handleToggleLike() {
      if (_libraryDetails == null) return;
      var newLibraryItem = _libraryDetails;
      newLibraryItem.isFavorite = !isFavorite;
      libraryProvider.updateLibraryItem(newLibraryItem);
      AlertsService.showSnackbar(newLibraryItem.isFavorite
          ? "Rom added to favorites"
          : "Rom removed from favorites");
    }

    handleAddToLibrary() {
      AlertsService.showSnackbar("Rom added to library");
      libraryProvider.addRomToLibrary(rom);
    }

    handleOpenConfigurations() {
      showDialog(
          context: context,
          builder: (dialog) {
            return RomSettingsDialog(rom: rom);
          });
    }

    iconButtonStyle() {
      return IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          padding: EdgeInsets.all(4),
          minimumSize:
              minimumSize != null ? Size(minimumSize!, minimumSize!) : null);
    }

    if (_libraryDetails == null) {
      return IconButton(
        iconSize: iconSize,
        style: iconButtonStyle(),
        icon: Icon(Icons.library_add),
        onPressed: handleAddToLibrary,
        color: Colors.grey,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: contentWidth,
          child: IconButton(
            iconSize: iconSize,
            style: iconButtonStyle(),
            icon: Icon(
              _libraryDetails.isFavorite == true
                  ? Icons.star
                  : Icons.star_border,
              color: isFavorite ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: () {
              handleToggleLike();
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            color: Colors.grey,
          ),
        ),
        SizedBox(
          width: spacing,
        ),
        Container(
          width: contentWidth,
          child: IconButton(
            iconSize: iconSize,
            style: iconButtonStyle(),
            icon: Icon(Icons.tune),
            onPressed: handleOpenConfigurations,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
