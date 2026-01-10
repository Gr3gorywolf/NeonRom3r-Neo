import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/models/emulator_setting.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/services/emulator_service.dart';
import 'package:yamata_launcher/ui/widgets/app_selection_dialog.dart';

class EmulatorSettingsForm extends StatefulWidget {
  final List<String> existingConsoles;
  final Function(EmulatorSetting) onSubmit;
  final EmulatorSetting? editingSetting;
  const EmulatorSettingsForm(
      {super.key,
      required this.existingConsoles,
      required this.onSubmit,
      this.editingSetting});

  @override
  State<EmulatorSettingsForm> createState() => _EmulatorSettingsFormState();
}

class _EmulatorSettingsFormState extends State<EmulatorSettingsForm> {
  List<String> availableConsoles = [];
  String selectedConsole = "";
  String selectedBinary = "";
  @override
  void initState() {
    availableConsoles = ConsoleService.getConsoles()
        .map((e) => e.slug ?? "")
        .where((slug) => !widget.existingConsoles.contains(slug))
        .toList();
    if (widget.editingSetting != null) {
      selectedConsole = widget.editingSetting!.console;
      selectedBinary = widget.editingSetting!.emulatorBinary;
    } else if (availableConsoles.isNotEmpty) {
      selectedConsole = availableConsoles.first;
    }

    super.initState();
  }

  void handleSelectEmulatorBinary() async {
    if (Platform.isAndroid) {
      var consoleEmulators =
          EmulatorService.getEmulatorPackagesForConsole(selectedConsole);
      var result = await AppSelectionDialog.show(context,
          filteredApps: consoleEmulators);
      if (result != null) {
        setState(() {
          selectedBinary = result.packageName;
        });
      }
      return;
    }
    FilePickerResult? selectedFile = await FilePicker.platform.pickFiles(
      dialogTitle: "Select Emulator Binary",
      type: FileType.custom,
      initialDirectory: Platform.isMacOS ? "/Applications" : null,
      allowedExtensions: VALID_EXECUTABLE_EXTENSIONS,
    );
    if (selectedFile != null) {
      setState(() {
        selectedBinary = selectedFile.files.single.path ?? "";
      });
    }
  }

  void handleSave() {
    if (selectedConsole.isEmpty || selectedBinary.isEmpty) {
      AlertsService.showErrorSnackbar(
          "Please select a console and emulator binary path",
          ctx: context);
      return;
    }
    EmulatorSetting setting = EmulatorSetting(
      console: selectedConsole,
      emulatorBinary: selectedBinary,
    );
    widget.onSubmit(setting);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Emulator Setting'),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      contentPadding: const EdgeInsets.all(15.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedConsole.isNotEmpty ? selectedConsole : null,
            items: availableConsoles
                .map((consoleSlug) => DropdownMenuItem<String>(
                      value: consoleSlug,
                      child: Text(ConsoleService.getConsoleFromName(consoleSlug)
                              ?.name ??
                          ""),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedConsole = value ?? "";
              });
            },
          ),
          SizedBox(height: 22),
          ElevatedButton(
              onPressed: handleSelectEmulatorBinary,
              child: Row(
                children: [
                  Icon(Icons.file_open),
                  SizedBox(width: 8),
                  Text(
                      "Select Emulator ${Platform.isAndroid ? "application" : "binary"}"),
                ],
              )),
          if (selectedBinary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                selectedBinary,
                maxLines: 4,
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
