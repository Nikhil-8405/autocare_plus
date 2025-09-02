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
      appBar: AppBar(
        title: const Text("Vehicle Report"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Table(
            border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
            },
            children: [
              _buildHeaderRow(),
              _buildDataRow("Total Service Cost", "₹${totalServiceCost.toStringAsFixed(2)}"),
              _buildDataRow("Total Distance Driven", "${totalDistance.toStringAsFixed(1)} km"),
              _buildDataRow("Total Fuel Consumed", "${totalFuel.toStringAsFixed(1)} litres"),
              _buildDataRow("Average Mileage", "${avgMileage.toStringAsFixed(1)} km/l"),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blue.shade100),
      children: const [
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Metric',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Value',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  TableRow _buildDataRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
