// lib/features/dashboard/screens/notice_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/notice_model.dart';

class NoticeDetailScreen extends StatelessWidget {
  final Notice notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    // Format the date for display
    final formattedDate = DateFormat('MMMM d, yyyy').format(notice.createdAt.toDate());

    return Scaffold(
      appBar: AppBar(
        // The AppBar title can be simple or show the notice title
        title: const Text("Notice Details"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notice Title
            Text(
              notice.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Author and Date
            Text(
              'Posted by: ${notice.author} on $formattedDate',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(height: 32, thickness: 1),
            // Full Notice Content
            Text(
              notice.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5, // Improves readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}