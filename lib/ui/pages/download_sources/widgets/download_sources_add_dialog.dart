import 'package:flutter/material.dart';
import 'package:neonrom3r/models/download_source.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/repository/download_sources_repository.dart';
import 'package:neonrom3r/utils/download_sources_helper.dart';
import 'package:provider/src/provider.dart';

class DownloadSourceAddDialog extends StatefulWidget {
  String sourceUrl = '';
  bool isFetchingSource = false;

  @override
  State<DownloadSourceAddDialog> createState() =>
      _DownloadSourceAddDialogState();
}

class _DownloadSourceAddDialogState extends State<DownloadSourceAddDialog> {
  final _controller = TextEditingController();
  Future handleAddSource() async {
    setState(() {
      widget.isFetchingSource = true;
    });

    try {
      final source =
          await DownloadSourcesRepository().fetchSource(widget.sourceUrl);

      if (source != null) {
        print(source.toJson());
        final provider = context.read<DownloadSourcesProvider>();
        provider.addDownloadSource(source);
        Navigator.pop(context);
      } else {
        // Handle error: source could not be fetched
        print("source is null");
      }
    } catch (e) {
      // Handle error: exception occurred
      print(e);
    } finally {
      setState(() {
        widget.isFetchingSource = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DownloadSourcesProvider>();

    return AlertDialog(
      title: Text('New source'),
      content: TextField(
        onChanged: (value) => widget.sourceUrl = value,
        decoration: const InputDecoration(
          labelText: 'Source title',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            handleAddSource();
          },
          child: Row(
            children: [
              widget.isFetchingSource
                  ? CircularProgressIndicator()
                  : Icon(Icons.add),
              SizedBox(width: 8),
              Text('Add source'),
            ],
          ),
        ),
      ],
    );
  }
}
