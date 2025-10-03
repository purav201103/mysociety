// lib/features/staff/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mysociety/core/models/visitor_model.dart';
import 'package:mysociety/features/staff/screens/gate_visitor_detail_screen.dart';
import 'package:mysociety/services/visitor_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isNavigating = false;

  void _handleDetection(BarcodeCapture capture) async {
    if (_isNavigating) return; // Prevent multiple navigations

    final String? visitorId = capture.barcodes.first.rawValue;

    if (visitorId != null) {
      setState(() { _isNavigating = true; });

      final Visitor? visitor = await VisitorService().getVisitorById(visitorId: visitorId);

      if (mounted) {
        // Pop the scanner screen off the stack
        Navigator.of(context).pop();

        if (visitor != null) {
          // Push the detail screen for the found visitor
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => GateVisitorDetailScreen(visitor: visitor),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid or expired visitor pass.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Visitor Pass')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            onDetect: _handleDetection,
          ),
          // Simple overlay to guide the user
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}