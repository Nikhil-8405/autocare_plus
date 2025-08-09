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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final db = DBHelper();
      await db.deleteVehicle(vehicleId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle deleted")),
      );
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
          ? const Center(child: Text("No vehicles found."))
          : ListView.builder(
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return Card(
            child: ListTile(
              title: Text(
                "${vehicle['brand']} ${vehicle['model']}" ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Reg No: ${vehicle['number'] ?? ''} • Year: ${vehicle['year'] ?? ''}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navigateToAddEdit(vehicle: vehicle),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
