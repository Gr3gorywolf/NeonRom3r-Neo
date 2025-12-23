import 'package:flutter/material.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/console_source.dart';
import 'package:yamata_launcher/repository/console_sources_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:provider/provider.dart';
import 'package:yamata_launcher/providers/download_sources_provider.dart';
import 'package:yamata_launcher/models/download_source.dart';

class ConsoleSourcesPage extends StatefulWidget {
  @override
  _ConsoleSourcesPageState createState() => _ConsoleSourcesPageState();
}

class _ConsoleSourcesPageState extends State<ConsoleSourcesPage> {
  handleSetConsoleSource() async {
    var result = await AlertsService.showPrompt(context, 'Add Console Source',
        inputPlaceholder: 'Enter console source URL',
        message:
            "The console source must be a valid URL pointing to a JSON file containing console definitions.");
    if (result != null && result.isNotEmpty) {
      try {
        final source = await ConsoleSourcesRepository().fetchSource(result);
        if (source != null) {
          source.downloadUrl = result;
          bool added = await ConsoleService.addConsoleSource(source);
          if (added) {
            setState(() {});
            AlertsService.showSnackbar(
                context, "Console source added successfully.");
          } else {
            AlertsService.showErrorSnackbar(context,
                exception: Exception("Console source already exists."));
          }
        } else {
          AlertsService.showErrorSnackbar(context,
              exception: Exception("Failed to fetch console source."));
        }
      } catch (e) {
        AlertsService.showErrorSnackbar(context,
            exception: Exception("Failed to fetch console source."));
      }
    }
  }

  handleUpdateConsoleSource(Console sourceToUpdate) async {
    var source = await ConsoleService.getConsoleSource(sourceToUpdate);
    if (source == null) {
      AlertsService.showErrorSnackbar(context,
          exception: Exception("Failed to fetch console source."));
      return;
    }
    final updatedSource =
        await ConsoleSourcesRepository().fetchSource(source.downloadUrl ?? "");
    if (updatedSource != null) {
      updatedSource.downloadUrl = source.downloadUrl;
      bool added = await ConsoleService.updateConsoleSource(updatedSource);
      if (added) {
        setState(() {});
        AlertsService.showSnackbar(
            context, "Console source updated successfully.");
      } else {
        AlertsService.showErrorSnackbar(context,
            exception: Exception("Console source doesn't exist."));
      }
    } else {
      AlertsService.showErrorSnackbar(context,
          exception: Exception("Failed to fetch console source."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console Sources'),
      ),
      body: Builder(
        builder: (builder) {
          if (ConsoleService.consolesFromExternalSources.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No console sources',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => handleSetConsoleSource(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add source'),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: ConsoleService.consolesFromExternalSources.length,
            itemBuilder: (_, index) {
              final source = ConsoleService.consolesFromExternalSources[index];
              return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                        (source.name ?? "") + " " + (source.altName ?? "")),
                    subtitle:
                        Opacity(opacity: 0.7, child: Text(source.slug ?? "")),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            ConsoleService.deleteConsoleSource(source);
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            handleUpdateConsoleSource(source);
                          },
                        ),
                      ],
                    ),
                  ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: handleSetConsoleSource,
        child: const Icon(Icons.add),
      ),
    );
  }
}
