import 'package:flutter/material.dart';
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: _mileage.isEmpty
                ? const Center(child: Text("No mileage records found."))
                : ListView.builder(
              itemCount: _mileage.length,
              itemBuilder: (context, index) {
                final entry = _mileage[index];
                final double km = (entry['kilometers'] ?? 0).toDouble();
                final double fuel = (entry['fuel'] ?? 1).toDouble();
                final avg = fuel > 0 ? km / fuel : 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.local_gas_station),
                    title: Text("${km.toStringAsFixed(1)} km  •  ${avg.toStringAsFixed(1)} km/l"),
                    subtitle: Text(entry['date'] ?? ""),
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
