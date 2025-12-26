import 'dart:io';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

class UnzipDialog extends StatefulWidget {
  final File zipFile;
  static Future<File?> show(BuildContext context, File zipFile) {
    return showDialog<File?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UnzipDialog(zipFile: zipFile),
    );
  }

  const UnzipDialog({super.key, required this.zipFile});

  @override
  State<UnzipDialog> createState() => _UnzipDialogState();
}

class _UnzipDialogState extends State<UnzipDialog> {
  double progress = 0;
  String status = "Preparing…";

  @override
  void initState() {
    super.initState();
    _unzip();
  }

  Future<void> _unzip() async {
    try {
      final bytes = await widget.zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final dir = widget.zipFile.parent.path;
      int index = 0;
      File? firstFile;

      for (final file in archive) {
        if (file.isFile) {
          final outPath = p.join(dir, file.name);
          final outFile = File(outPath)..createSync(recursive: true);
          outFile.writeAsBytesSync(file.content as List<int>);

          firstFile ??= outFile;
        } else {
          Directory(p.join(dir, file.name)).createSync(recursive: true);
        }

        index++;
        setState(() {
          status = "Extracting ${file.name}";
          progress = index / archive.length;
        });

        await Future.delayed(Duration(milliseconds: 10));
      }
      await widget.zipFile.delete();

      if (mounted) Navigator.pop(context, firstFile);
    } catch (e) {
      if (!mounted) return;
      setState(() => status = "Error: $e");
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context, null);
    }
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
