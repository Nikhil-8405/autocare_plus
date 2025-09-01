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
      Navigator.pop(context, vehicleId);
    } else {
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
          Navigator.pop(context, vehicleId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Vehicle"),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      body: _vehicles.isEmpty
          ? const Center(
        child: Text(
          "No vehicles found.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _vehicles.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _handleVehicleTap(vehicle['id']),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.directions,
                        size: 30, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle['model'] ?? 'Unknown Model',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle['number'] ?? 'No Number',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
