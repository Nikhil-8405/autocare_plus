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
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      final db = DBHelper();
      Map<String, dynamic> vehicleData = {
        'user_id': widget.userId,
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'number': _numberController.text.trim(),
        'year': _yearController.text.trim(),
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
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _numberController.dispose();
    _yearController.dispose();
    super.dispose();
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter brand' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter model' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Registration Number'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter registration number' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter year';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                    return 'Enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _saveVehicle,
                child: Text(isEditing ? 'Update Vehicle' : 'Add Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
