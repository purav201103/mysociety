// lib/features/admin/widgets/all_parking_spots_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mysociety/features/admin/screens/assign_vehicle_to_spot_screen.dart';
import 'package:mysociety/features/admin/screens/reassign_spot_screen.dart';
import 'package:mysociety/services/parking_service.dart';
import 'package:mysociety/services/vehicle_service.dart';

class AllParkingSpotsView extends StatefulWidget {
  const AllParkingSpotsView({super.key});
  @override
  State<AllParkingSpotsView> createState() => _AllParkingSpotsViewState();
}

class _AllParkingSpotsViewState extends State<AllParkingSpotsView> {
  String _selectedType = '4-Wheeler';

  @override
  Widget build(BuildContext context) {
    final ParkingService parkingService = ParkingService();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(8.0),
            isSelected: [_selectedType == '4-Wheeler', _selectedType == '2-Wheeler'],
            onPressed: (index) => setState(() => _selectedType = index == 0 ? '4-Wheeler' : '2-Wheeler'),
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('4-Wheeler Spots')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('2-Wheeler Spots')),
            ],
          ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
          label: Text('Delete All Available $_selectedType Spots', style: const TextStyle(color: Colors.red)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirm Bulk Deletion'),
                content: Text('Are you sure you want to delete ALL available $_selectedType spots? This cannot be undone.'),
                actions: [
                  TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
                  TextButton(
                    child: const Text('DELETE ALL', style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await parkingService.deleteAllAvailableSpots(spotType: _selectedType);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: parkingService.getAllParkingSpotsStream(spotType: _selectedType),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('No $_selectedType spots found.'));

              final spots = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: spots.length,
                itemBuilder: (context, index) {
                  final spot = spots[index];
                  final spotData = spot.data() as Map<String, dynamic>;
                  final bool isAvailable = spotData['status'] == 'Available';
                  return Card(
                    color: isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        isAvailable ? Icons.local_parking : _selectedType == '4-Wheeler' ? Icons.directions_car : Icons.two_wheeler,
                        size: 40,
                        color: isAvailable ? Colors.green : Colors.black54,
                      ),
                      title: Text(spotData['spotNumber'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(isAvailable ? 'Available - Tap to assign' : 'Assigned to: ${spotData['assignedVehicleNumber']}'),
                      trailing: Icon(isAvailable ? Icons.add_circle_outline : Icons.edit_note_outlined, color: isAvailable ? Colors.green : Colors.blue),
                      onTap: () {
                        if (isAvailable) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AssignVehicleToSpotScreen(
                              spotId: spot.id,
                              spotNumber: spotData['spotNumber'],
                              spotType: spotData['spotType'],
                            ),
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ReassignSpotScreen(spot: spot),
                          ));
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}