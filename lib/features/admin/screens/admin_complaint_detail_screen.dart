// lib/features/admin/screens/admin_complaint_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/complaint_model.dart';
import 'package:mysociety/features/complaints/widgets/comment_section_widget.dart';
import 'package:mysociety/services/complaint_service.dart';
import 'package:mysociety/services/staff_service.dart';

class AdminComplaintDetailScreen extends StatefulWidget {
  final Complaint complaint;
  const AdminComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<AdminComplaintDetailScreen> createState() => _AdminComplaintDetailScreenState();
}

class _AdminComplaintDetailScreenState extends State<AdminComplaintDetailScreen> {
  late String _currentStatus;
  final ComplaintService _complaintService = ComplaintService();
  final StaffService _staffService = StaffService();
  String? _selectedStaffId;
  List<QueryDocumentSnapshot> _staffList = [];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.complaint.status;
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    _staffList = await _staffService.getStaffList();
    setState(() {});
  }

  Future<void> _saveChanges() async {
    try {
      if (_selectedStaffId != null) {
        final selectedStaffDoc = _staffList.firstWhere((doc) => doc.id == _selectedStaffId);
        await _complaintService.assignComplaint(
          complaintId: widget.complaint.id,
          staffUid: selectedStaffDoc['uid'],
          staffName: selectedStaffDoc['name'],
        );
      } else {
        await _complaintService.updateComplaintStatus(
          complaintId: widget.complaint.id,
          newStatus: _currentStatus,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint updated successfully!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.complaint.title)),
      body: Column(
        children: [
          // Top section for details - scrollable
          Expanded(
            flex: 3, // Give more space to details
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Resident: ${widget.complaint.residentName}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  Text('Submitted: ${DateFormat('d MMM, yyyy').format(widget.complaint.submittedAt.toDate())}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  const Divider(height: 24),
                  if (widget.complaint.imageUrl != null && widget.complaint.imageUrl!.isNotEmpty) ...[
                    const Text('Attached Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(widget.complaint.imageUrl!),
                    ),
                    const Divider(height: 24),
                  ],
                  Text(widget.complaint.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const Divider(height: 24),
                  const Text('Assign To', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    hint: const Text('Select Staff Member'),
                    items: _staffList.map((doc) => DropdownMenuItem(value: doc.id, child: Text(doc['name']))).toList(),
                    onChanged: (value) => setState(() => _selectedStaffId = value),
                  ),
                  const SizedBox(height: 16),
                  const Text('Update Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _currentStatus,
                    items: ['Open', 'In Progress', 'Resolved'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (value) { if (value != null) setState(() { _currentStatus = value; }); },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: _saveChanges, child: const Text('Save Changes')),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Discussion", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          // Bottom section for comments
          Expanded(
            flex: 2, // Give less space to comments
            child: CommentSectionWidget(complaintId: widget.complaint.id),
          ),
        ],
      ),
    );
  }
}