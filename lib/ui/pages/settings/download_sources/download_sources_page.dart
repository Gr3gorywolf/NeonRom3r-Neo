import 'package:flutter/material.dart';
import 'package:yamata_launcher/repository/download_sources_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/ui/pages/settings/download_sources/widgets/download_sources_empty_state.dart';
import 'package:yamata_launcher/ui/pages/settings/download_sources/widgets/download_sources_list_item.dart';
import 'package:provider/provider.dart';
import 'package:yamata_launcher/providers/download_sources_provider.dart';
import 'package:yamata_launcher/models/download_source.dart';

class DownloadSourcesPage extends StatefulWidget {
  @override
  _DownloadSourcesPageState createState() => _DownloadSourcesPageState();
}

class _DownloadSourcesPageState extends State<DownloadSourcesPage> {
  handleAddSource() async {
    var result = await AlertsService.showPrompt(context, "Add Download Source",
        message: "Enter the URL of the download source:",
        inputPlaceholder: "Source URL");
    if (result == null || result.isEmpty) {
      return;
    }
    final source = await DownloadSourcesRepository().fetchSource(result);

    if (source != null) {
      print(source.toJson());
      final provider = context.read<DownloadSourcesProvider>();
      var success = await provider.addDownloadSource(source);
      if (success) {
        AlertsService.showSnackbar(context, "Source added successfully");
      } else {
        AlertsService.showErrorSnackbar(context,
            exception: Exception("This source already exists"));
      }
    } else {
      AlertsService.showErrorSnackbar(context,
          exception: Exception("Could not fetch source"));
    }
  }

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
            return DownloadSourcesEmptyState(onAdd: handleAddSource);
          }

          return ListView.builder(
            itemCount: provider.downloadSources.length,
            itemBuilder: (_, index) {
              final source = provider.downloadSources[index];
              return DownloadSourceListItem(
                source: source,
                onDelete: () => provider.removeDownloadSource(source),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: handleAddSource,
        child: const Icon(Icons.add),
      ),
    );
  }
}
