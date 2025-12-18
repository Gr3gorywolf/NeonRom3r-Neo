import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';

class ConsoleSourcesListItem extends StatelessWidget {
  final Console console;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ConsoleSourcesListItem({
    required this.console,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(console.slug ?? ""),
        subtitle: Text(console.name ?? ""),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
