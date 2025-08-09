import 'package:flutter/material.dart';
import 'package:autocare_plus/screens/add_edit_vehicle.dart';
import 'package:autocare_plus/screens/vehicle_list.dart';
import 'package:autocare_plus/screens/profile.dart';
import 'package:autocare_plus/screens/add_service.dart';
import 'package:autocare_plus/screens/service_history.dart';
import 'package:autocare_plus/screens/select_vehicle.dart';
import 'package:autocare_plus/screens/add_mileage.dart';
import 'package:autocare_plus/screens/mileage_log.dart';
import 'package:autocare_plus/screens/report.dart';
import 'package:autocare_plus/screens/reminder.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Reminders';
      case 2:
        return 'Reports';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      _buildHomeScreen(context),
      RemindersScreen(userId: widget.user['id']),
      SelectVehicleScreen(userId: widget.user['id'], nextScreen: 'report'),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Reminders"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome, ${widget.user['username'] ?? 'User'}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildTile(context, Icons.add_circle, "Add Vehicle", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditVehicleScreen(userId: widget.user['id']),
                  ),
                );
              }),
              _buildTile(context, Icons.list_alt, "Vehicle List", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleListScreen(userId: widget.user['id']),
                  ),
                );
              }),
              _buildTile(context, Icons.add_task, "Add Service", () async {
                final selectedVehicleId = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectVehicleScreen(userId: widget.user['id']),
                  ),
                );
                if (selectedVehicleId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddServiceScreen(vehicleId: selectedVehicleId),
                    ),
                  );
                }
              }),
              _buildTile(context, Icons.history, "Service History", () async {
                final selectedVehicleId = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectVehicleScreen(userId: widget.user['id']),
                  ),
                );
                if (selectedVehicleId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceHistoryScreen(vehicleId: selectedVehicleId),
                    ),
                  );
                }
              }),
              _buildTile(context, Icons.add_road, "Add Mileage", () async {
                final selectedVehicleId = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectVehicleScreen(userId: widget.user['id']),
                  ),
                );
                if (selectedVehicleId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMileageScreen(vehicleId: selectedVehicleId),
                    ),
                  );
                }
              }),
              _buildTile(context, Icons.local_gas_station, "Mileage Log", () async {
                final selectedVehicleId = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectVehicleScreen(userId: widget.user['id']),
                  ),
                );
                if (selectedVehicleId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MileageLogScreen(vehicleId: selectedVehicleId),
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
