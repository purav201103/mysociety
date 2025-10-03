// lib/features/admin/screens/parking_management_screen.dart
import 'package:flutter/material.dart';
import 'package:mysociety/features/admin/screens/create_parking_spots_screen.dart';
import 'package:mysociety/features/admin/widgets/admin_vehicle_list_view.dart';
import 'package:mysociety/features/admin/widgets/all_parking_spots_view.dart';
import 'package:mysociety/features/admin/widgets/assigned_vehicle_list_view.dart';

class ParkingManagementScreen extends StatefulWidget {
  const ParkingManagementScreen({super.key});

  @override
  State<ParkingManagementScreen> createState() => _ParkingManagementScreenState();
}

class _ParkingManagementScreenState extends State<ParkingManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController for 3 tabs
    _tabController = TabController(length: 3, vsync: this);
    // Add a listener to rebuild the widget when the tab changes,
    // which is needed to show/hide the FloatingActionButton.
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Unassigned'),
            Tab(text: 'Assigned'),
            Tab(text: 'All Spots'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminVehicleListView(),    // Tab 1 Content
          AssignedVehicleListView(), // Tab 2 Content
          AllParkingSpotsView(),     // Tab 3 Content
        ],
      ),
      // Only show the "Add Spots" button on the "All Spots" tab
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const CreateParkingSpotsScreen(),
          ));
        },
        label: const Text('Create Spots'),
        icon: const Icon(Icons.add),
      )
          : null,
    );
  }
}