import 'package:flutter/material.dart';
import 'package:autocare_plus/db/db_helper.dart';

class AddServiceScreen extends StatefulWidget {
  final int vehicleId;

  const AddServiceScreen({super.key, required this.vehicleId});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final service = {
        'vehicle_id': widget.vehicleId,
        'service_type': _serviceTypeController.text,
        'service_date': _dateController.text,
        'cost': double.tryParse(_costController.text) ?? 0.0,
        'notes': _notesController.text,
      };

      await DBHelper().insertService(service);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Service record added")),
      );

      Navigator.pop(context); // Go back to previous screen
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      _dateController.text = selected.toIso8601String().split('T').first;
    }
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _dateController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Service Record")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _serviceTypeController,
                decoration: const InputDecoration(labelText: "Service Type"),
                validator: (value) => value!.isEmpty ? "Enter service type" : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: "Service Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (value) => value!.isEmpty ? "Pick a date" : null,
              ),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cost (₹)"),
                validator: (value) => value!.isEmpty ? "Enter cost" : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Notes (optional)"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Add Service"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
