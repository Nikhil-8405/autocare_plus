import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import 'add_service.dart';
import 'mileage_log.dart';
import 'add_mileage.dart';
import 'service_history.dart';
import 'report.dart';

class SelectVehicleScreen extends StatefulWidget {
  final int userId;
  final String? nextScreen;

  const SelectVehicleScreen({
    super.key,
    required this.userId,
    this.nextScreen,
  });

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
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

  void _handleVehicleTap(int vehicleId) {
    if (widget.nextScreen == null) {
      Navigator.pop(context, vehicleId); // Default behavior
    } else {
      // Navigate based on nextScreen value
      switch (widget.nextScreen) {
        case 'report':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReportsScreen(vehicleId: vehicleId)),
          );
          break;
        case 'add_service':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddServiceScreen(vehicleId: vehicleId)),
          );
          break;
        case 'mileage_log':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MileageLogScreen(vehicleId: vehicleId)),
          );
          break;
        case 'add_mileage':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMileageScreen(vehicleId: vehicleId)),
          );
          break;
        case 'service_history':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ServiceHistoryScreen(vehicleId: vehicleId)),
          );
          break;
        default:
          Navigator.pop(context, vehicleId); // Fallback
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Vehicle")),
      body: _vehicles.isEmpty
          ? const Center(child: Text("No vehicles found."))
          : ListView.builder(
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return ListTile(
            title: Text(vehicle['model'] ?? 'Unknown Model'),
            subtitle: Text(vehicle['number'] ?? 'No Number'),
            onTap: () => _handleVehicleTap(vehicle['id']),
          );
        },
      ),
    );
  }
}
