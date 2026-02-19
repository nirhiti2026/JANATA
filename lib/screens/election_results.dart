import 'package:flutter/material.dart';

class ElectionResults extends StatelessWidget {
  const ElectionResults({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo placeholder - can be replaced with charts/data later.
    final items = [
      {'name': 'Politician A', 'votes': 1240},
      {'name': 'Politician B', 'votes': 980},
      {'name': 'Politician C', 'votes': 560},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Election Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Election Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items.map((i) => ListTile(title: Text(i['name'] as String), trailing: Text(i['votes'].toString())))
          ],
        ),
      ),
    );
  }
}