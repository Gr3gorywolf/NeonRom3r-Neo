import 'package:flutter/material.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/providers/library_provider.dart';
import 'package:neonrom3r/services/alerts_service.dart';
import 'package:provider/provider.dart';

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

    if (size == RomLibraryActionSize.small) {
      minimumSize = 30;
      iconSize = 18;
    } else if (size == RomLibraryActionSize.large) {
      minimumSize = 40;
      iconSize = 26;
    }

    handleToggleLike() {
      if (_libraryDetails == null) return;
      var newLibraryItem = _libraryDetails;
      newLibraryItem.isFavorite = !isFavorite;
      libraryProvider.updateLibraryItem(newLibraryItem);
      AlertsService.showSnackbar(
          context,
          newLibraryItem.isFavorite
              ? "Rom added to favorites"
              : "Rom removed from favorites");
    }

    handleAddToLibrary() {
      AlertsService.showSnackbar(context, "Rom added to library");
      libraryProvider.addRomToLibrary(rom);
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
      children: [
        IconButton(
          iconSize: iconSize,
          style: iconButtonStyle(),
          icon: Icon(
            _libraryDetails.isFavorite == true ? Icons.star : Icons.star_border,
            color: isFavorite ? Theme.of(context).colorScheme.primary : null,
          ),
          onPressed: () {
            handleToggleLike();
          },
          color: Colors.grey,
        ),
        SizedBox(
          width: 8,
        ),
        IconButton(
          iconSize: iconSize,
          style: iconButtonStyle(),
          icon: Icon(Icons.tune),
          onPressed: () {},
          color: Colors.grey,
        ),
      ],
    );
  }
}
