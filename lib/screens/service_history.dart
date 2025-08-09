import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class ServiceHistoryScreen extends StatelessWidget {
  final int vehicleId;

  const ServiceHistoryScreen({super.key, required this.vehicleId});

  Future<List<Map<String, dynamic>>> _loadServiceHistory() async {
    return await DBHelper().getServicesByVehicleId(vehicleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service History")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadServiceHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No service records found."));
          }

          final services = snapshot.data!;
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(service['service_type'] ?? "No Type"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${service['service_date']}"),
                      Text("Notes: ${service['notes']?.toString().trim().isNotEmpty == true ? service['notes'] : 'No note'}"),
                    ],
                  ),
                  trailing: Text("₹${service['cost']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
