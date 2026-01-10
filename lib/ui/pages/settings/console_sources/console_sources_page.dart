import 'package:flutter/material.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/console_source.dart';
import 'package:yamata_launcher/repository/console_sources_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:provider/provider.dart';
import 'package:yamata_launcher/providers/download_sources_provider.dart';
import 'package:yamata_launcher/models/download_source.dart';
import 'package:yamata_launcher/ui/widgets/empty_placeholder.dart';

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
      var loading = AlertsService.showLoadingAlert(
          context,
          "Downloading console source...",
          "Please wait while the console source is being downloaded...");
      final source = await ConsoleSourcesRepository().fetchSource(result);
      loading.close();
      if (source != null) {
        source.downloadUrl = result;
        bool added = await ConsoleService.addConsoleSource(source);
        if (added) {
          setState(() {});
          AlertsService.showSnackbar("Console source added successfully.",
              ctx: context);
        } else {
          AlertsService.showErrorSnackbar("Console source already exists.",
              ctx: context);
        }
      } else {
        AlertsService.showErrorSnackbar("Failed to fetch console source.",
            ctx: context);
      }
    }
  }

  handleUpdateConsoleSource(Console sourceToUpdate) async {
    var source = await ConsoleService.getConsoleSource(sourceToUpdate);
    if (source == null) {
      AlertsService.showErrorSnackbar("Failed to fetch console source.",
          ctx: context);
      return;
    }
    var loading = AlertsService.showLoadingAlert(
        context,
        "Updating console source...",
        "Please wait while the console source is being updated...");
    final updatedSource =
        await ConsoleSourcesRepository().fetchSource(source.downloadUrl ?? "");
    loading.close();
    if (updatedSource != null) {
      updatedSource.downloadUrl = source.downloadUrl;
      bool added = await ConsoleService.updateConsoleSource(updatedSource);
      if (added) {
        setState(() {});
        AlertsService.showSnackbar("Console source updated successfully.",
            ctx: context);
      } else {
        AlertsService.showErrorSnackbar("Console source doesn't exist.",
            ctx: context);
      }
    } else {
      AlertsService.showErrorSnackbar("Failed to fetch console source.",
          ctx: context);
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
            return EmptyPlaceholder(
              icon: Icons.gamepad,
              title: 'No console sources',
              description:
                  "You have not added any console sources yet. Add a source to view more game catalogs.",
              action: PlaceHolderAction(
                label: 'Add Source',
                onPressed: () => handleSetConsoleSource(),
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
                    title: Text((source.altName ?? "")),
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
      floatingActionButton: !ConsoleService.consolesFromExternalSources.isEmpty
          ? FloatingActionButton.extended(
              onPressed: handleSetConsoleSource,
              icon: const Icon(Icons.add),
              label: const Text('Add Console Source'),
            )
          : null,
    );
  }
}
