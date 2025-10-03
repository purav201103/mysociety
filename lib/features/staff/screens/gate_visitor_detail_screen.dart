// lib/features/staff/screens/gate_visitor_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/visitor_model.dart';
import 'package:mysociety/services/visitor_service.dart';

class GateVisitorDetailScreen extends StatelessWidget {
  final Visitor visitor;
  const GateVisitorDetailScreen({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    final visitorService = VisitorService();

    return Scaffold(
      appBar: AppBar(title: Text(visitor.visitorName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Details", style: Theme.of(context).textTheme.titleLarge),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text("Visiting: ${visitor.residentName}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Purpose: ${visitor.purpose}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Expected At: ${DateFormat('d MMM, h:mm a').format(visitor.expectedAt.toDate())}", style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const Spacer(), // Pushes buttons to the bottom
            if (visitor.status == 'Expected')
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Mark as Arrived'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async {
                  await visitorService.markVisitorArrived(visitorId: visitor.id);
                  if(context.mounted) Navigator.of(context).pop();
                },
              ),
            if (visitor.status == 'Arrived')
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Mark as Departed'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async {
                  await visitorService.markVisitorDeparted(visitorId: visitor.id);
                  if(context.mounted) Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}