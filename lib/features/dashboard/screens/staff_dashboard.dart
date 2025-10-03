// lib/features/dashboard/screens/staff_dashboard.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/admin/widgets/all_parking_spots_view.dart'; // Re-use the admin widget
import 'package:mysociety/features/authentication/services/auth_service.dart';
import 'package:mysociety/features/staff/screens/qr_scanner_screen.dart';
import 'package:mysociety/features/staff/widgets/gate_visitor_list_view.dart';
import 'package:mysociety/features/staff/widgets/staff_complaint_list_view.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});
  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _selectedIndex = 0;

  // Add the new page to the list
  final List<Widget> _pages = [
    const StaffComplaintListView(),
    const GateVisitorListView(),
    const AllParkingSpotsView(), // The new page
  ];
  final List<String> _pageTitles = ['My Tasks', 'Visitor Gate', 'Parking Status'];

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        actions: [
          // Show scan button only on the Visitors tab
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: 'Scan QR Pass',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QrScannerScreen(),
                ));
              },
            ),
          IconButton(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Visitors'),
          BottomNavigationBarItem(icon: Icon(Icons.local_parking), label: 'Parking'), // The new tab
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}