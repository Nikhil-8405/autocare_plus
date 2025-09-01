import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';

class MileageLogScreen extends StatefulWidget {
  final int vehicleId;
  const MileageLogScreen({super.key, required this.vehicleId});

  @override
  State<MileageLogScreen> createState() => _MileageLogScreenState();
}

class _MileageLogScreenState extends State<MileageLogScreen> {
  List<Map<String, dynamic>> _mileage = [];

  @override
  void initState() {
    super.initState();
    _loadMileage();
  }

  Future<void> _loadMileage() async {
    final db = DBHelper();
    final data = await db.getMileageByVehicleId(widget.vehicleId);
    setState(() {
      _mileage = data;
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalKm = 0;
    double totalFuel = 0;

    for (var entry in _mileage) {
      totalKm += (entry['kilometers'] ?? 0).toDouble();
      totalFuel += (entry['fuel'] ?? 0).toDouble();
    }

    double totalAvg = totalFuel > 0 ? totalKm / totalFuel : 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Mileage Log")),
      body: Column(
        children: [
          if (_mileage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Total Average: ${totalAvg.toStringAsFixed(1)} km/l",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          Expanded(
            child: _mileage.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.local_gas_station, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No mileage records found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _mileage.length,
              itemBuilder: (context, index) {
                final entry = _mileage[index];
                final double km = (entry['kilometers'] ?? 0).toDouble();
                final double fuel = (entry['fuel'] ?? 1).toDouble();
                final avg = fuel > 0 ? km / fuel : 0;
                final formattedDate = _formatDate(entry['date'] ?? '');

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.local_gas_station, color: Colors.white),
                    ),
                    title: Text(
                      "${km.toStringAsFixed(1)} km  •  ${avg.toStringAsFixed(1)} km/l",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(formattedDate),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
