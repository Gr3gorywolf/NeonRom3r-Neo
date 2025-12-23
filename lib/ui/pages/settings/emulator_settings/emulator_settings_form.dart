import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/constants/files_constants.dart';
import 'package:neonrom3r/models/emulator_setting.dart';
import 'package:neonrom3r/services/alerts_service.dart';
import 'package:neonrom3r/services/console_service.dart';

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
    }

    super.initState();
  }

  void handleSelectEmulatorBinary() async {
    FilePickerResult? selectedFile = await FilePicker.platform.pickFiles(
      dialogTitle: "Select Emulator Binary",
      type: FileType.custom,
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
      AlertsService.showErrorSnackbar(context,
          exception:
              Exception("Please select a console and emulator binary path"));
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
      contentPadding: const EdgeInsets.all(15.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Console',
            ),
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
                  const Text('Select Emulator binary'),
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
        ElevatedButton(
          onPressed: handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
