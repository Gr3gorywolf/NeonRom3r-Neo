import 'package:flutter/material.dart';
import 'package:yamata_launcher/repository/download_sources_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:provider/provider.dart';
import 'package:yamata_launcher/providers/download_sources_provider.dart';
import 'package:yamata_launcher/models/download_source.dart';

class DownloadSourcesPage extends StatefulWidget {
  @override
  _DownloadSourcesPageState createState() => _DownloadSourcesPageState();
}

class _DownloadSourcesPageState extends State<DownloadSourcesPage> {
  _handleDeleteSource(DownloadSourceWithDownloads source) async {
    final confirmed = await AlertsService.showAlert(
      context,
      "Delete Download Source",
      "Are you sure you want to delete the source '${source.sourceInfo!.title}'?",
      callback: () {
        final provider =
            Provider.of<DownloadSourcesProvider>(context, listen: false);
        provider.removeDownloadSource(source);
        AlertsService.showSnackbar("Source deleted successfully");
      },
    );
  }

  _handleSetSource(DownloadSourceWithDownloads? sourceToUpdate) async {
    var result = sourceToUpdate == null
        ? await AlertsService.showPrompt(context, "Add Download Source",
            message: "Enter the URL of the download source:",
            inputPlaceholder: "Source URL")
        : sourceToUpdate.sourceInfo!.downloadUrl;
    if (result == null || result.isEmpty) {
      return;
    }
    var loadingHandle = AlertsService.showLoadingAlert(context,
        "Fetching Source", "Please wait while the source is being fetched...");
    final source = await DownloadSourcesRepository().fetchSource(result);
    loadingHandle.close();
    if (source != null) {
      source.sourceInfo.downloadUrl = result;
      final provider =
          Provider.of<DownloadSourcesProvider>(context, listen: false);
      var success = await provider.setDownloadSource(source);
      if (success) {
        AlertsService.showSnackbar(
            sourceToUpdate == null
                ? "Source added successfully"
                : "Source updated successfully",
            ctx: context);
      } else {
        AlertsService.showErrorSnackbar("This source already exists",
            ctx: context);
      }
    } else {
      AlertsService.showErrorSnackbar("Could not fetch source", ctx: context);
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
          if (provider.downloadSources.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No download sources',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _handleSetSource(null),
                    icon: const Icon(Icons.add),
                    label: const Text('Add source'),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.downloadSources.length,
            itemBuilder: (_, index) {
              final source = provider.downloadSources[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(source.sourceInfo!.title!),
                  subtitle: Opacity(
                      opacity: 0.7,
                      child:
                          Text('${source.downloads!.length} roms available')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _handleDeleteSource(source),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => _handleSetSource(source),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleSetSource(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
