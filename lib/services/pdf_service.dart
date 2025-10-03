// lib/services/pdf_service.dart
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/invoice_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// We have removed the 'printing' package for now to debug

class PdfService {
  Future<void> generateInvoiceStatement(List<Invoice> invoices, Map<String, dynamic> userProfile) async {
    final pdf = pw.Document();

    // The methods to build the PDF content are the same
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(userProfile),
            _buildInvoiceTable(invoices),
            _buildSummary(invoices),
          ];
        },
      ),
    );

    // This new logic saves the PDF to a file and opens it
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/MySociety_Statement.pdf');
    await file.writeAsBytes(bytes);

    // Ask the OS to open the file
    await OpenFilex.open(file.path);
  }

  // The helper methods to build the PDF are unchanged
  pw.Widget _buildHeader(Map<String, dynamic> userProfile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('MySociety Maintenance Statement', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Text('Resident: ${userProfile['name']}'),
        pw.Text('Email: ${userProfile['email']}'),
        pw.Text('Date: ${DateFormat('d MMMM, yyyy').format(DateTime.now())}'),
        pw.SizedBox(height: 30),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildInvoiceTable(List<Invoice> invoices) {
    final headers = ['Month & Year', 'Due Date', 'Status', 'Amount'];
    final data = invoices.map((invoice) {
      return [
        '${invoice.month} ${invoice.year}',
        DateFormat('d MMM, yyyy').format(invoice.dueDate.toDate()),
        invoice.status,
        '₹${invoice.amount.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: { 3: pw.Alignment.centerRight },
    );
  }

  pw.Widget _buildSummary(List<Invoice> invoices) {
    final double totalPaid = invoices
        .where((inv) => inv.status == 'Paid')
        .fold(0, (sum, inv) => sum + inv.amount);

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Total Paid: ₹${totalPaid.toStringAsFixed(2)}',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }
}