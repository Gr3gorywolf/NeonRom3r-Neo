import 'package:flutter/material.dart';
import 'package:neonrom3r/models/download_source.dart';

class DownloadSourceListItem extends StatelessWidget {
  final DownloadSourceWithDownloads source;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DownloadSourceListItem({
    @required this.source,
    @required this.onEdit,
    @required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(source.sourceInfo.title),
        subtitle: Text('${source.downloads.length} roms available'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
