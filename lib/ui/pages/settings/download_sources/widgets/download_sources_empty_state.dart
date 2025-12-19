import 'package:flutter/material.dart';

class DownloadSourcesEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const DownloadSourcesEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'No download sources',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add source'),
          )
        ],
      ),
    );
  }
}
