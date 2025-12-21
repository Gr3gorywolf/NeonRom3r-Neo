import 'package:flutter/material.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:provider/provider.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/models/download_source.dart';

class RomDownloadSourcesDialog extends StatelessWidget {
  final RomInfo rom;

  const RomDownloadSourcesDialog({
    Key? key,
    required this.rom,
  }) : super(key: key);

  // ---------------- BUILD ----------------

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DownloadSourcesProvider>();

    final List<DownloadSourceWithDownloads> results =
        provider.findRomSourcesWithDownloads(rom);
    final List<_Result> filteredResults = [];
    for (final source in results) {
      for (final sourceDownload in source.downloads!) {
        filteredResults.add(_Result(
          rom: sourceDownload,
          sourceTitle: source.sourceInfo!.title,
        ));
      }
    }

    return AlertDialog(
      title: const Text('Available downloads'),
      content: SizedBox(
        width: 420,
        height: 420,
        child: results.isEmpty
            ? const Center(
                child: Text(
                  'No matching ROMs found',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: filteredResults.length,
                itemBuilder: (_, index) {
                  final item = filteredResults[index];
                  return ListTile(
                    leading: const Icon(Icons.gamepad),
                    title: Text(
                      item.rom.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${item.sourceTitle} • ${item.rom.fileSize}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(context, item.rom);
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _Result {
  final DownloadSourceRom rom;
  final String? sourceTitle;

  _Result({
    required this.rom,
    required this.sourceTitle,
  });
}
