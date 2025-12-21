import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/console_source.dart';
import 'package:neonrom3r/ui/pages/settings/console_sources/widgets/console_sources_add_dialog.dart';
import 'package:neonrom3r/ui/pages/settings/console_sources/widgets/console_sources_list_item.dart';
import 'package:neonrom3r/ui/pages/settings/download_sources/widgets/download_sources_add_dialog.dart';
import 'package:neonrom3r/ui/pages/settings/download_sources/widgets/download_sources_empty_state.dart';
import 'package:neonrom3r/ui/pages/settings/download_sources/widgets/download_sources_list_item.dart';
import 'package:neonrom3r/services/console_service.dart';
import 'package:provider/provider.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/models/download_source.dart';

import 'widgets/console_sources_empty_state.dart';

class ConsoleSourcesPage extends StatefulWidget {
  @override
  _ConsoleSourcesPageState createState() => _ConsoleSourcesPageState();
}

class _ConsoleSourcesPageState extends State<ConsoleSourcesPage> {
  handleOpenCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => ConsoleSourceAddDialog(
        onSave: (ConsoleSource source) {
          ConsoleService.addConsoleSource(source);
          setState(() {});
        },
      ),
    );
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
