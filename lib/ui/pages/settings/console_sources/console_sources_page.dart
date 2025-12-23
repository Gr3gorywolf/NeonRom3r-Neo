import 'package:flutter/material.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/console_source.dart';
import 'package:yamata_launcher/repository/console_sources_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/ui/pages/settings/console_sources/widgets/console_sources_add_dialog.dart';
import 'package:yamata_launcher/ui/pages/settings/console_sources/widgets/console_sources_list_item.dart';
import 'package:yamata_launcher/ui/pages/settings/download_sources/widgets/download_sources_empty_state.dart';
import 'package:yamata_launcher/ui/pages/settings/download_sources/widgets/download_sources_list_item.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:provider/provider.dart';
import 'package:yamata_launcher/providers/download_sources_provider.dart';
import 'package:yamata_launcher/models/download_source.dart';

import 'widgets/console_sources_empty_state.dart';

class ConsoleSourcesPage extends StatefulWidget {
  @override
  _ConsoleSourcesPageState createState() => _ConsoleSourcesPageState();
}

class _ConsoleSourcesPageState extends State<ConsoleSourcesPage> {
  handleOpenCreateDialog() async {
    var result = await AlertsService.showPrompt(context, 'Add Console Source',
        inputPlaceholder: 'Enter console source URL',
        message:
            "The console source must be a valid URL pointing to a JSON file containing console definitions.");
    if (result != null && result.isNotEmpty) {
      try {
        final source = await ConsoleSourcesRepository().fetchSource(result);
        if (source != null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console Sources'),
      ),
      body: Builder(
        builder: (builder) {
          if (ConsoleService.consolesFromSources.isEmpty) {
            return ConsoleSourcesEmptyState(onAdd: handleOpenCreateDialog);
          }

          return ListView.builder(
            itemCount: ConsoleService.consolesFromSources.length,
            itemBuilder: (_, index) {
              final source = ConsoleService.consolesFromSources[index];
              return ConsoleSourcesListItem(
                console: source,
                onEdit: () => {},
                onDelete: () => {
                  ConsoleService.deleteConsoleSource(source),
                  setState(() {}),
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: handleOpenCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
