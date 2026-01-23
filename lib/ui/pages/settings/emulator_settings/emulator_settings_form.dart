import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yamata_launcher/constants/console_constants.dart';
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/emulator_setting.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/services/emulator_service.dart';
import 'package:yamata_launcher/ui/widgets/app_selection_dialog.dart';
import 'package:yamata_launcher/ui/widgets/searchable_dropdown_form_field.dart';

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
  List<Console> availableConsoles = [];
  String selectedConsole = "";
  String selectedBinary = "";
  @override
  void initState() {
    availableConsoles =
        ConsoleService.getConsoles(includeAdditional: true, unique: true)
            .where((console) => !widget.existingConsoles.contains(console.slug))
            .toList();
    if (widget.editingSetting != null) {
      selectedConsole = widget.editingSetting!.console;
      selectedBinary = widget.editingSetting!.emulatorBinary;
    } else if (availableConsoles.isNotEmpty) {
      selectedConsole = availableConsoles.first.slug ?? "";
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
          SearchableDropdownFormField<String>(
            value: selectedConsole.isNotEmpty ? selectedConsole : null,
            items: availableConsoles
                .map((console) => DropdownMenuItem<String>(
                      value: console.slug ?? "",
                      child: Text(console.name ?? ""),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedConsole = value ?? "";
              });
            },
          ),
          SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: handleSelectEmulatorBinary,
            label: Text(
                "Select Emulator ${Platform.isAndroid ? "application" : "binary"}"),
            icon: Icon(Icons.videogame_asset),
          ),
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
