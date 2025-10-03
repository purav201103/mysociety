// lib/features/notices/screens/notices_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/dashboard/widgets/notice_list_view.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Society Notices')),
      body: const NoticeListView(),
    );
  }
}