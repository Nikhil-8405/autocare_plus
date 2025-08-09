import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class ReportsScreen extends StatefulWidget {
  final int vehicleId;
  const ReportsScreen({super.key, required this.vehicleId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double totalServiceCost = 0;
  double totalDistance = 0;
  double totalFuel = 0;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    final db = DBHelper();
    final services = await db.getServicesByVehicleId(widget.vehicleId);
    final mileage = await db.getMileageByVehicleId(widget.vehicleId);

    setState(() {
      totalServiceCost = services.fold(0, (sum, item) => sum + (item['cost'] ?? 0));
      totalDistance = mileage.fold(0, (sum, item) => sum + (item['kilometers'] ?? 0));
      totalFuel = mileage.fold(0, (sum, item) => sum + (item['fuel'] ?? 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    final avgMileage = totalFuel > 0 ? totalDistance / totalFuel : 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Report")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildReportTile("Total Service Cost", "₹${totalServiceCost.toStringAsFixed(2)}"),
            _buildReportTile("Total Distance Driven", "${totalDistance.toStringAsFixed(1)} km"),
            _buildReportTile("Total Fuel Added", "${totalFuel.toStringAsFixed(1)} litres"),
            _buildReportTile("Average Mileage", "${avgMileage.toStringAsFixed(1)} km/l"),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.analytics),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
