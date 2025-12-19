import 'package:flutter/material.dart';
import 'package:neonrom3r/ui/pages/settings/download_sources/widgets/download_sources_add_dialog.dart';
import 'package:neonrom3r/ui/pages/settings/download_sources/widgets/download_sources_empty_state.dart';
import 'package:neonrom3r/ui/pages/settings/download_sources/widgets/download_sources_list_item.dart';
import 'package:provider/provider.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/models/download_source.dart';

class DownloadSourcesPage extends StatefulWidget {
  @override
  _DownloadSourcesPageState createState() => _DownloadSourcesPageState();
}

class _DownloadSourcesPageState extends State<DownloadSourcesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Sources'),
      ),
      body: Consumer<DownloadSourcesProvider>(
        builder: (_, provider, __) {
          if (!provider.initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.downloadSources.isEmpty) {
            return DownloadSourcesEmptyState(onAdd: () => _openEditor());
          }

          return ListView.builder(
            itemCount: provider.downloadSources.length,
            itemBuilder: (_, index) {
              final source = provider.downloadSources[index];
              return DownloadSourceListItem(
                source: source,
                onEdit: () => {},
                onDelete: () => provider.removeDownloadSource(source),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openEditor() {
    showDialog(
      context: context,
      builder: (_) => DownloadSourcesAddDialog(),
    );
  }
}
