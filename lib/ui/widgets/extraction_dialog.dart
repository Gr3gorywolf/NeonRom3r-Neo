import 'dart:io';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/services/extraction_service.dart';
import 'package:yamata_launcher/utils/system_helpers.dart';

class ExtractionDialog extends StatefulWidget {
  final File zipFile;
  static Future<File?> show(BuildContext context, File zipFile) {
    return showDialog<File?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ExtractionDialog(zipFile: zipFile),
    );
  }

  const ExtractionDialog({super.key, required this.zipFile});

  @override
  State<ExtractionDialog> createState() => _ExtractionDialogState();
}

class _ExtractionDialogState extends State<ExtractionDialog> {
  double progress = 0;
  String status = "Preparing…";

  @override
  void initState() {
    super.initState();
    _unzip();
  }

  Future<void> _unzip() async {
    var stream = await ExtractionService.extractOnce(
        input: widget.zipFile, output: widget.zipFile.parent);
    File? firstFile;
    await for (var event in stream) {
      if (event < 0) {
        setState(() {
          status = "Preparing…";
        });
        continue;
      }
      setState(() {
        progress = event;
        status = "Unzipping… ${progress.toStringAsFixed(2)}%";
      });
      if (progress >= 100) {
        await _handleComplete();
        break;
      }
    }
  }

  _handleComplete() async {
    var dir = widget.zipFile.parent;
    File? extractedFile = null;
    for (var file in dir.listSync(recursive: true)) {
      if (file is File &&
          VALID_ROM_EXTENSIONS
              .contains(SystemHelpers.getFileExtension(file.path))) {
        extractedFile = File(file.path);
        break;
      }
    }
    Navigator.of(context).pop(extractedFile);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Unzipping…"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 12),
          Text(status, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
