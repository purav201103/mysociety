// lib/features/resident/widgets/resident_invoice_list_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/invoice_model.dart';
import 'package:mysociety/services/invoice_service.dart';

class ResidentInvoiceListView extends StatelessWidget {
  const ResidentInvoiceListView({super.key});

  // (You can copy the _getStatusColor helper function here)
  Color _getStatusColor(String status) {
    return status == 'Paid' ? Colors.green.shade600 : Colors.orange.shade700;
  }

  void _showPaymentConfirmation(BuildContext context, String invoiceId, double amount) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: Text('Are you sure you want to pay ₹${amount.toStringAsFixed(2)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await InvoiceService().markInvoiceAsPaid(invoiceId: invoiceId);
                if (context.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text("Not logged in."));

    return StreamBuilder<QuerySnapshot>(
      stream: InvoiceService().getMyInvoicesStream(residentUid: uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('You have no invoices.'));
        }
        final invoices = snapshot.data!.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${invoice.month} ${invoice.year}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Chip(
                          label: Text(invoice.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: _getStatusColor(invoice.status),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text('Amount: ₹${invoice.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Due Date: ${DateFormat('d MMMM, yyyy').format(invoice.dueDate.toDate())}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    if (invoice.status == 'Pending')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showPaymentConfirmation(context, invoice.id, invoice.amount),
                          child: const Text('Pay Now'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}