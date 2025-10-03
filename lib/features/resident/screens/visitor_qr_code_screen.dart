// lib/features/resident/screens/visitor_qr_code_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/core/models/visitor_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class VisitorQrCodeScreen extends StatelessWidget {
  final Visitor visitor;
  const VisitorQrCodeScreen({super.key, required this.visitor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitor Pass')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Show this QR Code at the gate", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              QrImageView(
                data: visitor.id, // The QR code will contain the unique visitor document ID
                version: QrVersions.auto,
                size: 250.0,
              ),
              const SizedBox(height: 20),
              Text(visitor.visitorName, style: Theme.of(context).textTheme.headlineSmall),
              Text("Purpose: ${visitor.purpose}"),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share Pass'),
                onPressed: () {
                  Share.share('Visitor Pass for ${visitor.visitorName}. Please show this at the society gate.');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}