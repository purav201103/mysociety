// lib/features/admin/widgets/admin_invoice_list_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/invoice_model.dart';
import 'package:mysociety/services/invoice_service.dart';

class AdminInvoiceListView extends StatelessWidget {
  const AdminInvoiceListView({super.key});

  Color _getStatusColor(String status) {
    return status == 'Paid' ? Colors.green.shade600 : Colors.orange.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final InvoiceService invoiceService = InvoiceService();

    return StreamBuilder<QuerySnapshot>(
      stream: invoiceService.getAllInvoicesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No invoices have been generated yet.'));
        }

        final invoices = snapshot.data!.docs.map((doc) => Invoice.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Row(
                  children: [
                    // This Expanded widget takes up all available space on the left
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.residentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${invoice.month} ${invoice.year}\nDue: ${DateFormat('d MMM, yyyy').format(invoice.dueDate.toDate())}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // This Column stays on the right
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${invoice.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            invoice.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: _getStatusColor(invoice.status),
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
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