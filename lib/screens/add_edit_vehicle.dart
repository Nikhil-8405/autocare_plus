import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class AddEditVehicleScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic>? vehicle; // Optional for edit

  const AddEditVehicleScreen({super.key, required this.userId, this.vehicle});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _brandController.text = widget.vehicle!['brand'] ?? '';
      _modelController.text = widget.vehicle!['model'] ?? '';
      _numberController.text = widget.vehicle!['number'] ?? '';
      _yearController.text = widget.vehicle!['year'] ?? '';
    }
  }

  void _saveVehicle() async {
    final db = DBHelper();
    Map<String, dynamic> vehicleData = {
      'user_id': widget.userId,
      'brand': _brandController.text,
      'model': _modelController.text,
      'number': _numberController.text,
      'year': _yearController.text,
    };

    if (widget.vehicle != null) {
      // Update
      await db.updateVehicle(widget.vehicle!['id'], vehicleData);
    } else {
      // Insert
      await db.insertVehicle(vehicleData);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Vehicle" : "Add Vehicle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Registration Number'),
            ),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveVehicle,
              child: Text(isEditing ? 'Update Vehicle' : 'Add Vehicle'),
            )
          ],
        ),
      ),
    );
  }
}
