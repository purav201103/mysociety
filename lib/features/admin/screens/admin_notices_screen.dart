// lib/features/admin/screens/admin_notices_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/admin/screens/add_notice_screen.dart';
import 'package:mysociety/features/dashboard/widgets/notice_list_view.dart';

class AdminNoticesScreen extends StatelessWidget {
  const AdminNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notice Management')),
      body: const NoticeListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddNoticeScreen())),
        tooltip: 'Add Notice',
        child: const Icon(Icons.add),
      ),
    );
  }
}