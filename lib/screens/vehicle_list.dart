import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'add_edit_vehicle.dart';

class VehicleListScreen extends StatefulWidget {
  final int userId;
  const VehicleListScreen({super.key, required this.userId});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final db = DBHelper();
    final data = await db.getVehiclesByUserId(widget.userId);
    setState(() {
      _vehicles = data;
    });
  }

  void _navigateToAddEdit({Map<String, dynamic>? vehicle}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditVehicleScreen(
          userId: widget.userId,
          vehicle: vehicle,
        ),
      ),
    );
    _loadVehicles(); // refresh after add/edit
  }

  Future<void> _confirmDelete(int vehicleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Vehicle"),
        content: const Text("Are you sure you want to delete this vehicle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = DBHelper();
      await db.deleteVehicle(vehicleId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vehicle deleted")),
        );
      }
      _loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Vehicles"),
      ),
      body: _vehicles.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_car, size: 70, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No vehicles found.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          final brand = vehicle['brand'] ?? '';
          final model = vehicle['model'] ?? '';
          final regNo = vehicle['number'] ?? 'N/A';
          final year = vehicle['year']?.toString() ?? 'N/A';

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.directions_car, color: Colors.white),
              ),
              title: Text(
                "$brand $model",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                "Reg No: $regNo • Year: $year",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit Vehicle',
                    onPressed: () => _navigateToAddEdit(vehicle: vehicle),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Vehicle',
                    onPressed: () => _confirmDelete(vehicle['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Add Vehicle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
