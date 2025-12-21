import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/download_source.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/repository/download_sources_repository.dart';
import 'package:neonrom3r/services/download_sources_service.dart';
import 'package:provider/src/provider.dart';

import '../../../../../models/console_source.dart';
import '../../../../../repository/console_sources_repository.dart';

class ConsoleSourceAddDialog extends StatefulWidget {
  String sourceUrl = '';
  bool isFetchingSource = false;
  Function(ConsoleSource) onSave;
  ConsoleSourceAddDialog({required this.onSave});

  @override
  State<ConsoleSourceAddDialog> createState() => _ConsoleSourceAddDialogState();
}

class _ConsoleSourceAddDialogState extends State<ConsoleSourceAddDialog> {
  final _controller = TextEditingController();
  Future handleAddSource() async {
    setState(() {
      widget.isFetchingSource = true;
    });

    try {
      final source =
          await ConsoleSourcesRepository().fetchSource(widget.sourceUrl);

      if (source != null) {
        widget.onSave(source);
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
      title: Text('New console source'),
      content: TextField(
        onChanged: (value) => widget.sourceUrl = value,
        decoration: const InputDecoration(
          labelText: 'Console source URL',
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
