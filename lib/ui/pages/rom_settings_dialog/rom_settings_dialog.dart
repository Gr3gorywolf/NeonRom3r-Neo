import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/providers/library_provider.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/rom_service.dart';
import 'package:yamata_launcher/ui/widgets/app_selection_dialog.dart';
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

    _removeRomPath() async {
      if (libraryItem != null) {
        libraryItem.filePath = "";
        await provider.updateLibraryItem(libraryItem);
      }
    }

    _pickEmulatorBinary() async {
      if (Platform.isAndroid) {
        var result = await AppSelectionDialog.show(context);
        if (result != null && libraryItem != null) {
          libraryItem.overrideEmulator = result.packageName;
          await provider.updateLibraryItem(libraryItem);
        }
        return;
      }
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
            title: "Select Played Time",
            initialMinutes: libraryItem.playTimeMins?.toInt() ?? 0,
            onSubmit: (minutes) {
              libraryItem.playTimeMins = minutes.toDouble();
              provider.updateLibraryItem(libraryItem);
            },
          ),
        );
      }
    }

    _restoreTime() async {
      if (libraryItem != null) {
        libraryItem.playTimeMins = 0;
        await provider.updateLibraryItem(libraryItem);
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
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      contentPadding: const EdgeInsets.all(10.0),
      content: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingItem(
                title: "Rom path",
                content: Text(
                    _downloadPath.isEmpty ? "Not downloaded" : _downloadPath),
                icon: Icons.description,
                actions: [
                  ..._downloadPath.isEmpty
                      ? []
                      : [
                          IconButton(
                              icon: Icon(Icons.settings_backup_restore),
                              onPressed: _removeRomPath),
                        ],
                  IconButton(icon: Icon(Icons.edit), onPressed: _pickRomPath)
                ],
              ),
              _SettingItem(
                title: "Emulator override",
                content: Text(overrideEmulator.isEmpty
                    ? "Default Emulator"
                    : overrideEmulator),
                icon: Icons.videogame_asset,
                actions: [
                  ...overrideEmulator.isEmpty
                      ? []
                      : [
                          IconButton(
                              icon: Icon(Icons.settings_backup_restore),
                              onPressed: _restoreEmulator),
                        ],
                  IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _pickEmulatorBinary()),
                ],
              ),
              if (!Platform.isAndroid)
                _SettingItem(
                  title: "Launch parameters",
                  helperText:
                      "Parameters flags used when launching the ROM (if supported by the emulator)",
                  content: TextField(
                    controller: launchParameters,
                    decoration: InputDecoration(
                      hintText: "Custom launch parameters",
                      helperMaxLines: 3,
                      helperStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 7),
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
                  icon: Icons.terminal,
                  actions: [],
                ),
              _SettingItem(
                title: "Time played",
                content: Text(TimeHelpers.formatMinutes(
                    libraryItem?.playTimeMins.toInt() ?? 0)),
                icon: Icons.access_time,
                actions: [
                  ...((libraryItem?.playTimeMins.toInt() ?? 0) == 0
                      ? []
                      : [
                          IconButton(
                              icon: Icon(Icons.settings_backup_restore),
                              onPressed: _restoreTime),
                        ]),
                  IconButton(
                      icon: Icon(Icons.edit), onPressed: () => _pickTime()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text("Danger Zone",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.redAccent)),
              ),
              _DangerSettingItem(
                  title: "Remove from library",
                  enabled: true,
                  content: Text(
                      "This will delete configuration and metadata. The file will remain on disk"),
                  icon: Icons.dangerous,
                  actions: [
                    IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        onPressed: _removeFromLibrary)
                  ]),
              _DangerSettingItem(
                  title: "Delete files",
                  enabled: fileExists,
                  content: Text(
                      "Permanently delete the file from storage. The library entry will not be removed."),
                  icon: Icons.dangerous,
                  actions: fileExists
                      ? [
                          IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: _deleteRomFile)
                        ]
                      : []),
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

class _SettingItem extends StatelessWidget {
  final String title;
  final Widget content;
  final String? helperText;
  final IconData icon;
  final List<IconButton> actions;

  const _SettingItem(
      {required this.title,
      required this.content,
      this.helperText,
      required this.icon,
      required this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(title,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          ),
          SizedBox(height: 5),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: BoxConstraints(minHeight: 40),
                child: Row(
                  children: [
                    Icon(icon),
                    SizedBox(width: 10),
                    Expanded(child: content),
                    Row(children: actions)
                  ],
                ),
              ),
            ),
          ),
          if (helperText?.isNotEmpty ?? false)
            Opacity(
                opacity: 0.7,
                child: Container(
                  margin: EdgeInsets.only(bottom: 5, left: 4),
                  child: Text(helperText ?? '',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                )),
        ],
      ),
    );
  }
}

class _DangerSettingItem extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData icon;
  final List<IconButton> actions;
  final bool enabled;

  const _DangerSettingItem(
      {required this.title,
      required this.enabled,
      required this.content,
      required this.icon,
      required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: enabled ? Colors.redAccent : Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: ListTile(
          title: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: enabled ? Colors.redAccent : Colors.grey)),
          subtitle: Opacity(opacity: 0.6, child: content),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: actions,
          ),
        ));
  }
}
