import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';

class AddMileageScreen extends StatefulWidget {
  final int vehicleId;

  const AddMileageScreen({super.key, required this.vehicleId});

  @override
  State<AddMileageScreen> createState() => _AddMileageScreenState();
}

class _AddMileageScreenState extends State<AddMileageScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _fuelController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _kmController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final db = DBHelper();
      await db.insertMileage({
        'vehicle_id': widget.vehicleId,
        'date': _dateController.text,
        'kilometers': double.parse(_kmController.text),
        'fuel': double.parse(_fuelController.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mileage record added")),
      );

      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Mileage")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: "Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (value) => value!.isEmpty ? "Please select date" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(labelText: "Kilometers Driven"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter kilometers" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fuelController,
                decoration: const InputDecoration(labelText: "Fuel Added (litres)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter fuel added" : null,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Add Mileage"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
