import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yamata_launcher/constants/console_constants.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:yamata_launcher/ui/widgets/dialog_section_item.dart';
import 'package:yamata_launcher/ui/widgets/rom_scrape_dialog.dart';
import 'package:yamata_launcher/utils/string_helper.dart';

class LibraryImportDialog extends StatefulWidget {
  final Function(RomInfo info, String filePath) onPicked;

  const LibraryImportDialog({super.key, required this.onPicked});

  static show(
    BuildContext context,
    Function(RomInfo info, String filePath) onPicked,
  ) {
    showDialog(
      context: context,
      builder: (context) => LibraryImportDialog(onPicked: onPicked),
    );
  }

  @override
  State<LibraryImportDialog> createState() => _LibraryImportDialogState();
}

class _LibraryImportDialogState extends State<LibraryImportDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _submitted = false;

  bool _titleTouched = false;
  bool _consoleTouched = false;
  bool _fileTouched = false;

  String romPath = "";
  bool isFetchingMetadata = false;

  List<Console> consoles = [];
  String selectedConsole = "";
  String detailsUrl = "";

  final titleController = TextEditingController(text: "");
  final gameplayCoverController = TextEditingController(text: "");
  final coverController = TextEditingController(text: "");

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _coverFocus = FocusNode();
  final FocusNode _gameplayFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    consoles =
        ConsoleService.getConsoles(includeAdditional: true, unique: true);

    _titleFocus.addListener(() {
      if (!_titleFocus.hasFocus) {
        _titleTouched = true;
        _validate();
      }
    });

    _coverFocus.addListener(() {
      if (!_coverFocus.hasFocus) _validate();
    });

    _gameplayFocus.addListener(() {
      if (!_gameplayFocus.hasFocus) _validate();
    });

    titleController.addListener(_onAnyFieldChange);
    coverController.addListener(_onAnyFieldChange);
    gameplayCoverController.addListener(_onAnyFieldChange);
  }

  @override
  void dispose() {
    titleController.dispose();
    coverController.dispose();
    gameplayCoverController.dispose();

    _titleFocus.dispose();
    _coverFocus.dispose();
    _gameplayFocus.dispose();

    super.dispose();
  }

  void _onAnyFieldChange() => setState(() {});

  InputDecoration _inputDecoration({
    required String hintText,
    String? helperText,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      helperText: helperText,
      helperStyle: TextStyle(color: Colors.grey[500]),
      errorText: errorText,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _pickRomPath() async {
    _fileTouched = true;

    final file = await FileSystemService.locateFile();
    if (file == null) return;

    if (titleController.text.trim().isEmpty) {
      titleController.text = StringHelper.getTitleFromFile(file);
    }

    setState(() {
      romPath = file;
    });

    _validate();
  }

  void _validate() {
    setState(() {
      _formKey.currentState?.validate();
    });
  }

  String? _requiredValidator({
    required String value,
    required String fieldName,
  }) {
    if (value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  String? _urlValidatorOptional(String value, String fieldName) {
    final v = value.trim();
    if (v.isEmpty) return null;

    final uri = Uri.tryParse(v);
    final isValid = uri != null && uri.hasScheme && uri.isAbsolute;
    if (!isValid) return '$fieldName must be a valid URL';
    return null;
  }

  String? get _fileErrorText {
    final canShow = _submitted || _fileTouched;
    if (!canShow) return null;
    if (romPath.trim().isEmpty) return "ROM file is required";
    return null;
  }

  String? get _titleErrorText {
    final canShow = _submitted || _titleTouched;
    if (!canShow) return null;
    return _requiredValidator(
        value: titleController.text, fieldName: "ROM Title");
  }

  String? get _consoleErrorText {
    final canShow = _submitted || _consoleTouched;
    if (!canShow) return null;
    return _requiredValidator(value: selectedConsole, fieldName: "Console");
  }

  bool get _isImportEnabled {
    if (romPath.trim().isEmpty) return false;
    if (titleController.text.trim().isEmpty) return false;
    if (selectedConsole.trim().isEmpty) return false;

    final coverErr = _urlValidatorOptional(coverController.text, "Portrait");
    if (coverErr != null) return false;

    final gameplayErr =
        _urlValidatorOptional(gameplayCoverController.text, "Gameplay Cover");
    if (gameplayErr != null) return false;

    return true;
  }

  String? get _portraitErrorText {
    final canShow = _submitted || !_coverFocus.hasFocus;
    if (!canShow) return null;
    return _urlValidatorOptional(coverController.text, "Portrait");
  }

  String? get _gameplayErrorText {
    final canShow = _submitted || !_gameplayFocus.hasFocus;
    if (!canShow) return null;
    return _urlValidatorOptional(
        gameplayCoverController.text, "Gameplay Cover");
  }

  void _onScrape(RomInfo info) {
    setState(() {
      titleController.text = info.name;
      selectedConsole = info.console;
      detailsUrl = info.detailsUrl ?? "";
      coverController.text = info.portrait ?? "";
      gameplayCoverController.text = info.gameplayCovers?.isNotEmpty == true
          ? info.gameplayCovers!.first
          : "";
    });

    _validate();
  }

  void _onImport() {
    setState(() {
      _submitted = true;
      _titleTouched = true;
      _consoleTouched = true;
      _fileTouched = true;
    });

    _validate();

    if (!_isImportEnabled) return;

    final romInfo = RomInfo(
      slug: titleController.text.normalizeForSearch(),
      name: titleController.text.trim(),
      portrait: coverController.text.trim().isEmpty
          ? null
          : coverController.text.trim(),
      gameplayCovers: gameplayCoverController.text.trim().isEmpty
          ? null
          : [gameplayCoverController.text.trim()],
      console: selectedConsole.trim(),
      detailsUrl: detailsUrl.trim(),
    );

    widget.onPicked(romInfo, romPath);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final titleErr = _titleErrorText;
    final consoleErr = _consoleErrorText;
    final fileErr = _fileErrorText;

    final portraitErr = _portraitErrorText;
    final gameplayErr = _gameplayErrorText;

    return AlertDialog(
      title: const Text('Import ROM'),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      contentPadding: const EdgeInsets.all(10.0),
      content: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DialogSectionItem(
                  title: "ROM Title",
                  icon: Icons.title,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        RomScrapeDialog.show(
                          context,
                          titleController.text,
                          _onScrape,
                        );
                      },
                    ),
                  ],
                  helperText: titleErr,
                  helperTextIsError: titleErr != null,
                  content: TextFormField(
                    focusNode: _titleFocus,
                    controller: titleController,
                    decoration: _inputDecoration(
                      hintText: "Rom title",
                    ),
                    onFieldSubmitted: (_) {
                      RomScrapeDialog.show(
                        context,
                        titleController.text,
                        _onScrape,
                      );
                    },
                    validator: (_) => null,
                  ),
                ),
                DialogSectionItem(
                  title: "Console",
                  icon: Icons.videogame_asset,
                  actions: const [],
                  helperText: consoleErr,
                  helperTextIsError: consoleErr != null,
                  content: Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          selectedConsole.isNotEmpty ? selectedConsole : null,
                      items: consoles
                          .map((c) => DropdownMenuItem<String>(
                                value: c.slug,
                                child: Text(c.name ?? ""),
                              ))
                          .toList(),
                      hint: const Text("Select console"),
                      iconSize: 20,
                      decoration: _inputDecoration(
                        hintText: "Select console",
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedConsole = value ?? "";
                          _consoleTouched = true;
                        });
                        _validate();
                      },
                      validator: (_) => null,
                    ),
                  ),
                ),
                DialogSectionItem(
                  title: "ROM File",
                  icon: Icons.description,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: _pickRomPath,
                    ),
                  ],
                  helperText: fileErr ?? "Select the ROM file to import",
                  helperTextIsError: fileErr != null,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        romPath.isEmpty ? "No file selected" : romPath,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                DialogSectionItem(
                  title: "Portrait (Optional)",
                  icon: Icons.image,
                  actions: const [],
                  helperText: portraitErr,
                  helperTextIsError: portraitErr != null,
                  content: Row(
                    children: [
                      if (Uri.tryParse(coverController.text)?.isAbsolute ==
                          true)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            coverController.text,
                            height: 46,
                            width: 46,
                            cacheHeight: 180,
                            cacheWidth: 180,
                            key: ValueKey(coverController.text),
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (Uri.tryParse(coverController.text)?.isAbsolute ==
                          true)
                        const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          focusNode: _coverFocus,
                          controller: coverController,
                          decoration: _inputDecoration(
                            hintText: "Optional image URL",
                          ),
                          validator: (_) => null,
                          onChanged: (_) => _validate(),
                        ),
                      ),
                    ],
                  ),
                ),
                DialogSectionItem(
                  title: "Gameplay Cover (Optional)",
                  icon: Icons.collections,
                  actions: const [],
                  helperText: gameplayErr,
                  helperTextIsError: gameplayErr != null,
                  content: Row(
                    children: [
                      if (Uri.tryParse(gameplayCoverController.text)
                              ?.isAbsolute ==
                          true)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            gameplayCoverController.text,
                            height: 46,
                            width: 46,
                            cacheHeight: 180,
                            cacheWidth: 180,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (Uri.tryParse(gameplayCoverController.text)
                              ?.isAbsolute ==
                          true)
                        const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          focusNode: _gameplayFocus,
                          controller: gameplayCoverController,
                          decoration: _inputDecoration(
                            hintText: "Optional image URL",
                          ),
                          validator: (_) => null,
                          onChanged: (_) => _validate(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isImportEnabled ? _onImport : null,
          child: const Text('Import'),
        ),
      ],
    );
  }
}
