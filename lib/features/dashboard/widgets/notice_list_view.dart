// lib/features/dashboard/widgets/notice_list_view.dart

import 'package:mysociety/services/notice_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysociety/core/models/notice_model.dart';
import 'package:mysociety/features/dashboard/screens/notice_detail_screen.dart';

class NoticeListView extends StatelessWidget {
  const NoticeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final NoticeService noticeService = NoticeService();

    return StreamBuilder<QuerySnapshot>(
      stream: noticeService.getNoticesStream(),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Handle error state
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }
        // Handle no data state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No notices found.'));
        }

        // If we have data, display it in a list
        final notices = snapshot.data!.docs
            .map((doc) => Notice.fromFirestore(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            final notice = notices[index];
            final formattedDate =
            DateFormat('MMMM d, yyyy').format(notice.createdAt.toDate());

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  notice.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Posted on $formattedDate by ${notice.author}'),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NoticeDetailScreen(notice: notice),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}