// lib/features/staff/screens/staff_complaint_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/complaint_model.dart';
import 'package:mysociety/features/complaints/widgets/comment_section_widget.dart';
import 'package:mysociety/services/complaint_service.dart';

class StaffComplaintDetailScreen extends StatelessWidget {
  final Complaint complaint;
  const StaffComplaintDetailScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final complaintService = ComplaintService();

    return Scaffold(
      appBar: AppBar(title: Text(complaint.title)),
      body: Column(
        children: [
          // Top section for details
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Resident: ${complaint.residentName}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  Text('Submitted: ${DateFormat('d MMM, yyyy').format(complaint.submittedAt.toDate())}', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  const Divider(height: 24),
                  if (complaint.imageUrl != null && complaint.imageUrl!.isNotEmpty) ...[
                    const Text('Attached Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(complaint.imageUrl!),
                    ),
                    const Divider(height: 24),
                  ],
                  Text(complaint.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 40),
                  if (complaint.status != 'Resolved')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Resolved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        await complaintService.updateComplaintStatus(
                          complaintId: complaint.id,
                          newStatus: 'Resolved',
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
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
            flex: 2,
            child: CommentSectionWidget(complaintId: complaint.id),
          ),
        ],
      ),
    );
  }
}