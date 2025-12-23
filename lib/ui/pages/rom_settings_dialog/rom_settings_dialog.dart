import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/providers/library_provider.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/rom_service.dart';
import 'package:yamata_launcher/ui/widgets/duration_picker_dialog.dart';
import 'package:yamata_launcher/utils/time_helpers.dart';
import 'package:provider/provider.dart';

class RomSettingsDialog extends StatelessWidget {
  final RomInfo rom;
  RomSettingsDialog({super.key, required this.rom});
  var launchParameters = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<LibraryProvider>(context);
    var libraryItem = provider.getLibraryItem(rom.slug);
    var _downloadPath = libraryItem?.filePath ?? "";
    var overrideEmulator = libraryItem?.overrideEmulator ?? "";
    launchParameters.text = libraryItem?.openParams ?? "";
    var fileExists = _downloadPath.isNotEmpty;
    _pickRomPath() async {
      final selectedFiles =
          await FilePicker.platform.pickFiles(type: FileType.any);

      if (selectedFiles == null || libraryItem == null) return;
      libraryItem.filePath = selectedFiles.files.first.path ?? "";
      await provider.updateLibraryItem(libraryItem);
    }

    _pickEmulatorBinary() async {
      FilePickerResult? selectedFile = await FilePicker.platform.pickFiles(
        dialogTitle: "Select Emulator Binary",
        type: FileType.custom,
        allowedExtensions: VALID_EXECUTABLE_EXTENSIONS,
      );
      if (selectedFile == null || libraryItem == null) return;
      libraryItem.overrideEmulator = selectedFile.files.first.path ?? "";
      await provider.updateLibraryItem(libraryItem);
    }

    _restoreEmulator() async {
      if (libraryItem != null) {
        libraryItem.overrideEmulator = "";
        await provider.updateLibraryItem(libraryItem);
      }
    }

    _removeFromLibrary() async {
      await AlertsService.showAlert(context, "Remove from library",
          "Are you sure you want to remove this ROM from your library? all the rom settings will be removed as well (No files will be deleted)",
          callback: () async {
        await provider.removeLibraryItem(rom.slug);
        Navigator.of(context).pop();
      });
    }

    _pickTime() async {
      if (libraryItem != null) {
        showDialog<int>(
          context: context,
          builder: (context) => DurationPickerDialog(
            initialMinutes: libraryItem.playTimeMins?.toInt() ?? 0,
            onSubmit: (minutes) {
              libraryItem.playTimeMins = minutes.toDouble();
              provider.updateLibraryItem(libraryItem);
            },
          ),
        );
      }
    }

    _deleteRomFile() async {
      await AlertsService.showAlert(context, "Remove rom file",
          "Are you sure you want to remove this ROM from your computer? This action cannot be undone.",
          callback: () async {
        if (libraryItem != null && libraryItem.filePath!.isNotEmpty) {
          final file = File(libraryItem.filePath!);
          if (await file.exists()) {
            await file.delete();
          }
          libraryItem.filePath = "";
          await provider.updateLibraryItem(libraryItem);
        }
      });
    }

    return AlertDialog(
      title: Text('ROM Settings'),
      contentPadding: const EdgeInsets.all(10.0),
      content: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 800, minWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: "Path & Initialization"),
              ListTile(
                leading: const Icon(Icons.description),
                trailing:
                    IconButton(icon: Icon(Icons.edit), onPressed: _pickRomPath),
                title: const Text('Rom path'),
                subtitle: Opacity(
                    opacity: 0.7,
                    child: Text(_downloadPath.isEmpty
                        ? "Not downloaded"
                        : _downloadPath)),
              ),
              _SectionHeader(title: "Emulator"),
              ListTile(
                leading: const Icon(Icons.videogame_asset),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...overrideEmulator.isEmpty
                        ? []
                        : [
                            IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: _restoreEmulator),
                          ],
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _pickEmulatorBinary()),
                  ],
                ),
                title: const Text('Emulator override'),
                subtitle: Opacity(
                    opacity: 0.7,
                    child: Text(overrideEmulator.isEmpty
                        ? "Default Emulator"
                        : overrideEmulator)),
              ),
              SizedBox(height: 7),
              TextField(
                controller: launchParameters,
                decoration: InputDecoration(
                  hintText: "Custom launch parameters",
                  helperText:
                      "Parameters flags used when launching the ROM (if supported by the emulator)",
                  helperMaxLines: 3,
                  helperStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (text) {
                  libraryItem?.openParams = text;
                  if (libraryItem != null) {
                    provider.updateLibraryItem(libraryItem);
                  }
                },
              ),
              _SectionHeader(title: "Management"),
              ListTile(
                leading: const Icon(Icons.access_time),
                trailing: IconButton(
                    icon: Icon(Icons.edit), onPressed: () => _pickTime()),
                title: const Text('Update played time'),
                subtitle: Opacity(
                    opacity: 0.7,
                    child: Text("Time played: " +
                        TimeHelpers.formatMinutes(
                            libraryItem?.playTimeMins.toInt() ?? 0))),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: _removeFromLibrary,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 12)),
                      child: const Text('Remove from library')),
                  SizedBox(width: 12),
                  ElevatedButton(
                      onPressed: fileExists ? _deleteRomFile : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 12)),
                      child: const Text('Delete files'))
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 3),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
