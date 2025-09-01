import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';

class RemindersScreen extends StatefulWidget {
  final int userId;
  const RemindersScreen({super.key, required this.userId});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];
  List<Map<String, dynamic>> _vehicles = [];
  int? _selectedVehicleId;

  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _loadReminders();
  }

  Future<void> _loadVehicles() async {
    final db = DBHelper();
    final vehicles = await db.getVehiclesByUserId(widget.userId);
    setState(() {
      _vehicles = vehicles;
      if (vehicles.isNotEmpty) {
        _selectedVehicleId = vehicles.first['id'];
      }
    });
  }

  Future<void> _loadReminders() async {
    final db = DBHelper();
    final data = await db.getRemindersByUserId(widget.userId);
    setState(() {
      _reminders = data;
    });
  }

  Future<void> _addReminder() async {
    if (_titleController.text.isEmpty || _selectedDate == null || _selectedVehicleId == null) return;

    final reminder = {
      'user_id': widget.userId,
      'vehicle_id': _selectedVehicleId,
      'title': _titleController.text.trim(),
      'reminder_date': _selectedDate!.toIso8601String(),
      'notes': _notesController.text.trim(),
    };

    final db = DBHelper();
    await db.insertReminder(reminder);

    _titleController.clear();
    _notesController.clear();
    _selectedDate = null;
    _selectedVehicleId = _vehicles.isNotEmpty ? _vehicles.first['id'] : null;
    Navigator.pop(context);
    _loadReminders();
  }

  Future<void> _deleteReminder(int id) async {
    final db = DBHelper();
    await db.deleteReminder(id);
    _loadReminders();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Reminder"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: _notesController, decoration: const InputDecoration(labelText: "Notes")),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedVehicleId,
                decoration: const InputDecoration(labelText: "Select Vehicle"),
                items: _vehicles.map((vehicle) {
                  final label = "${vehicle['brand']} ${vehicle['model']} (${vehicle['number']})";
                  return DropdownMenuItem<int>(
                    value: vehicle['id'],
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedVehicleId = val;
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? "Select Date"
                          : DateFormat.yMMMMd().format(_selectedDate!),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  )
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addReminder, child: const Text("Add"))
        ],
      ),
    );
  }

  String _getVehicleLabel(int vehicleId) {
    final vehicle = _vehicles.firstWhere(
          (v) => v['id'] == vehicleId,
      orElse: () => {},
    );
    if (vehicle.isNotEmpty) {
      return "${vehicle['brand']} ${vehicle['model']} (${vehicle['number']})";
    }
    return "Vehicle";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text("Reminders")),
      body: _reminders.isEmpty
          ? const Center(child: Text("No reminders yet."))
          : ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return Card(
            child: ListTile(
              title: Text(
                  reminder['title'] ?? '' ,
                  style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${DateFormat.yMMMMd().format(DateTime.parse(reminder['reminder_date']))}\n"
                    "${(reminder['notes'] != null && reminder['notes'].toString().trim().isNotEmpty) ? reminder['notes'] : 'No note'}\n"
                    "Vehicle: ${_getVehicleLabel(reminder['vehicle_id'])}",
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteReminder(reminder['id']),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
