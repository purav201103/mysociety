// lib/features/admin/screens/admin_maintenance_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/admin/screens/generate_invoices_screen.dart';
import 'package:mysociety/features/admin/widgets/admin_invoice_list_view.dart';

class AdminMaintenanceScreen extends StatelessWidget {
  const AdminMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Invoices')),
      body: const AdminInvoiceListView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GenerateInvoicesScreen())),
        label: const Text('Generate Invoices'),
        icon: const Icon(Icons.add_card),
      ),
    );
  }
}