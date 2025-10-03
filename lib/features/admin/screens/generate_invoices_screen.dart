// lib/features/admin/screens/generate_invoices_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/services/invoice_service.dart';

class GenerateInvoicesScreen extends StatefulWidget {
  const GenerateInvoicesScreen({super.key});

  @override
  State<GenerateInvoicesScreen> createState() => _GenerateInvoicesScreenState();
}

class _GenerateInvoicesScreenState extends State<GenerateInvoicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedMonth;
  int? _selectedYear;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  final List<String> _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  final List<int> _years = List.generate(5, (index) => DateTime.now().year + index);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 15)), // Default to 15 days from now
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _generateInvoices() async {
    // Validate the form and that a due date has been selected
    if (_formKey.currentState!.validate() && _selectedDueDate != null) {
      setState(() { _isLoading = true; });
      try {
        await InvoiceService().generateInvoicesForAllResidents(
          amount: double.parse(_amountController.text),
          dueDate: _selectedDueDate!,
          month: _selectedMonth!,
          year: _selectedYear!,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoices generated successfully!')));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate invoices: $e')));
        }
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    } else if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a due date.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Monthly Invoices')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Maintenance Amount', border: OutlineInputBorder(), prefixText: '₹ '),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter an amount' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
                      items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (value) => setState(() => _selectedMonth = value),
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                      items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                      onChanged: (value) => setState(() => _selectedYear = value),
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListTile(
                  title: Text(_selectedDueDate == null
                      ? 'Select Due Date *'
                      : 'Due Date: ${DateFormat('dd MMMM, yyyy').format(_selectedDueDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDueDate(context),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _generateInvoices,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Generate for All Residents'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}