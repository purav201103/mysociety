// lib/features/directory/screens/contact_directory_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDirectoryScreen extends StatefulWidget {
  const ContactDirectoryScreen({super.key});
  @override
  State<ContactDirectoryScreen> createState() => _ContactDirectoryScreenState();
}

class _ContactDirectoryScreenState extends State<ContactDirectoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ADD THIS APPBAR. Flutter will automatically add the back button.
      appBar: AppBar(
        title: const Text("Contact Directory"),
      ),
      // We removed the SafeArea because the AppBar now handles the top space.
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Residents & Committee'),
              Tab(text: 'Staff'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ContactList(role: 'ResidentOrAdmin'),
                _ContactList(role: 'Staff'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// The _ContactList helper widget remains the same
class _ContactList extends StatelessWidget {
  final String role;
  const _ContactList({required this.role});

  Future<void> _launchUrl(String scheme, String path) async {
    final Uri url = Uri(scheme: scheme, path: path);
    if (!await launchUrl(url)) {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> stream = role == 'Staff'
        ? FirebaseFirestore.instance.collection('staff').snapshots()
        : FirebaseFirestore.instance.collection('users').where('role', whereIn: ['Resident', 'Committee/Admin']).snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No contacts found.'));
        }

        final contacts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contactData = contacts[index].data() as Map<String, dynamic>;
            final name = contactData['name'] ?? 'N/A';
            final phone = contactData['phone'] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(child: Text(name.isNotEmpty ? name.substring(0, 1) : "")),
                title: Text(name),
                subtitle: Text(contactData['role'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: phone.isNotEmpty ? () => _launchUrl('tel', phone) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.blue),
                      onPressed: phone.isNotEmpty ? () => _launchUrl('sms', phone) : null,
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