// lib/features/resident/screens/maintenance_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/services/invoice_service.dart';
import 'package:mysociety/services/pdf_service.dart';
import 'package:mysociety/services/user_service.dart';
import 'package:mysociety/features/resident/widgets/resident_invoice_list_view.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Download Statement',
            onPressed: () async {
              // Show a loading dialog while the PDF is being generated
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final uid = FirebaseAuth.instance.currentUser!.uid;
                // Fetch the data needed for the PDF
                final invoices = await InvoiceService().getMyInvoicesAsList(residentUid: uid);
                final userProfile = await UserService().getUserProfile(uid);

                // Hide the loading dialog
                if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

                if (invoices.isNotEmpty && userProfile != null) {
                  // If we have the data, generate and open the PDF
                  await PdfService().generateInvoiceStatement(invoices, userProfile);
                } else {
                  // If there's no data, show a message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No invoices found to generate a statement.')),
                    );
                  }
                }
              } catch (e) {
                // If any error occurs, hide the dialog and show the error
                if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An error occurred: $e')),
                  );
                }
                print("PDF Generation Error: $e");
              }
            },
          )
        ],
      ),
      body: const ResidentInvoiceListView(),
    );
  }
}