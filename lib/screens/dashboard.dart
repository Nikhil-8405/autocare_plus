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
import 'package:shared_preferences/shared_preferences.dart';

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
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _selectedIndex == 3
            ? [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();  // clear login state

              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ]
            : [],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _screens[_selectedIndex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade500,
        onTap: _onTabTapped,
        elevation: 8,
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
    final features = [
      {"icon": Icons.add_circle, "label": "Add Vehicle", "onTap": () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditVehicleScreen(userId: widget.user['id'])));
      }},
      {"icon": Icons.list_alt, "label": "Vehicle List", "onTap": () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => VehicleListScreen(userId: widget.user['id'])));
      }},
      {"icon": Icons.add_task, "label": "Add Service", "onTap": () async {
        final selectedVehicleId = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SelectVehicleScreen(userId: widget.user['id'])),
        );
        if (selectedVehicleId != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddServiceScreen(vehicleId: selectedVehicleId)));
        }
      }},
      {"icon": Icons.history, "label": "Service History", "onTap": () async {
        final selectedVehicleId = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SelectVehicleScreen(userId: widget.user['id'])),
        );
        if (selectedVehicleId != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceHistoryScreen(vehicleId: selectedVehicleId)));
        }
      }},
      {"icon": Icons.add_road, "label": "Add Mileage", "onTap": () async {
        final selectedVehicleId = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SelectVehicleScreen(userId: widget.user['id'])),
        );
        if (selectedVehicleId != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddMileageScreen(vehicleId: selectedVehicleId)));
        }
      }},
      {"icon": Icons.local_gas_station, "label": "Mileage Log", "onTap": () async {
        final selectedVehicleId = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SelectVehicleScreen(userId: widget.user['id'])),
        );
        if (selectedVehicleId != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MileageLogScreen(vehicleId: selectedVehicleId)));
        }
      }},
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Only Welcome text, no avatar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Welcome, ${widget.user['username'] ?? 'User'}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final item = features[index];
                return GestureDetector(
                  onTap: item["onTap"] as VoidCallback,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    shadowColor: Colors.blue.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item["icon"] as IconData, size: 50, color: Colors.blue.shade600),
                        const SizedBox(height: 10),
                        Text(item["label"] as String,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
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
