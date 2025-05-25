import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/group_trip.dart';

class GroupTripForm extends StatefulWidget {
  const GroupTripForm({Key? key}) : super(key: key);

  @override
  State<GroupTripForm> createState() => _GroupTripFormState();
}

class _GroupTripFormState extends State<GroupTripForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxMembersController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _submitForm() async {
    print("Submit button pressed"); // You already have this

    // Add these debug statements
    bool isFormValid = _formKey.currentState!.validate();
    bool isDateSelected = _selectedDate != null;

    print("Form valid: $isFormValid");
    print("Date selected: $isDateSelected");
    print("Selected date: $_selectedDate");

    if (isFormValid && isDateSelected) {
      print("Attempting to save..."); // Add this

      try {
        final newTrip = GroupTrip(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          location: _locationController.text.trim(),
          date: _selectedDate!,
          maxMembers: int.parse(_maxMembersController.text.trim()),
        );

        print("Trip object created: ${newTrip.toMap()}"); // Add this

        await FirebaseFirestore.instance
            .collection('group_trips')
            .add(newTrip.toMap());

        print("Trip saved successfully!"); // Add this

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Group trip posted!')));
        Navigator.pop(context);
      } catch (e) {
        print("Error saving trip: $e"); // Add this
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      print("Form validation failed or date not selected"); // Add this
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Create Group Trip"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_titleController, "Trip Title"),
              _buildTextField(_descController, "Description", maxLines: 3),
              _buildTextField(_locationController, "Location"),
              _buildDatePicker(context),
              _buildTextField(
                _maxMembersController,
                "Max Participants",
                isNumber: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitForm,
                child: Text("Post Trip", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator:
            (value) =>
                value == null || value.trim().isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
      title: Text(
        _selectedDate == null
            ? "Select Trip Date"
            : "Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
      ),
      trailing: Icon(Icons.calendar_today, color: Colors.orange),
      onTap: _pickDate,
    );
  }
}
