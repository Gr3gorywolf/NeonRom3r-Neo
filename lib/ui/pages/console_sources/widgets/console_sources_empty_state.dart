import 'package:flutter/material.dart';

class ConsoleSourcesEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const ConsoleSourcesEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'No external console sources',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add console source'),
          )
        ],
      ),
    );
  }
}
