import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupTripForm extends StatefulWidget {
  const GroupTripForm({Key? key}) : super(key: key);

  @override
  State<GroupTripForm> createState() => _GroupTripFormState();
}

class _GroupTripFormState extends State<GroupTripForm> {
  final _formKey = GlobalKey<FormState>();
  final orangeColor = const Color(0xFFE3641F);

  // Controllers
  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _travellersController = TextEditingController();
  final _budgetController = TextEditingController();
  final _departureCityController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _interestsController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedTripType;
  String? _selectedAccommodationType;
  String? _selectedTransportationMode;
  DateTime? _startDate;
  DateTime? _endDate;
  int _duration = 0;

  @override
  void dispose() {
    [
      _tripNameController,
      _destinationController,
      _travellersController,
      _budgetController,
      _departureCityController,
      _activitiesController,
      _interestsController,
      _organizerNameController,
      _emailController,
      _phoneController,
    ].forEach((c) => c.dispose());
    super.dispose();
  }

  void _calculateDuration() {
    if (_startDate != null && _endDate != null) {
      setState(() {
        _duration = _endDate!.difference(_startDate!).inDays + 1;
      });
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: isStart ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(_startDate!))
            _endDate = null;
        } else {
          _endDate = date;
        }
        _calculateDuration();
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null ||
        _selectedTripType == null ||
        _selectedAccommodationType == null ||
        _selectedTransportationMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and select dates'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'testUser123';

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await FirebaseFirestore.instance.collection('group_trips').add({
        'title': _tripNameController.text,
        'destination': _destinationController.text,
        'tripType': _selectedTripType!,
        'startDate': _startDate!,
        'endDate': _endDate!,
        'duration': _duration,
        'maxMembers': int.parse(_travellersController.text),
        'budget': double.parse(_budgetController.text),
        'accommodationType': _selectedAccommodationType!,
        'departureCity': _departureCityController.text,
        'transportationMode': _selectedTransportationMode!,
        'activities': _activitiesController.text,
        'organizerName': _organizerNameController.text,
        'organizerEmail': _emailController.text,
        'organizerPhone': _phoneController.text,
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [uid],
        'memberCount': 1,
        'status': 'active',
      });

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('published the post'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Wait a bit for the user to see the message, then close the form
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.pop(context);

      print('Error saving trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: const Text(
          'Create Group Trip',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('🌍 Trip Details'),
              _buildTextField('Trip Name', _tripNameController),
              _buildTextField('Destination', _destinationController),
              _buildDropdown(
                'Trip Type',
                [
                  'Leisure/Vacation',
                  'Business',
                  'Adventure',
                  'Cultural/Educational',
                  'Romantic Getaway',
                  'Family Trip',
                  'Group Travel',
                ],
                _selectedTripType,
                (v) => setState(() => _selectedTripType = v),
              ),

              // Date Selection with Calendar Icons
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTile(
                            'Start Date',
                            _startDate,
                            () => _selectDate(true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateTile(
                            'End Date',
                            _endDate,
                            () => _selectDate(false),
                          ),
                        ),
                      ],
                    ),
                    if (_duration > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: orangeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: orangeColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Duration: $_duration days',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: orangeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              _buildTextField(
                'Max Travelers',
                _travellersController,
                isNumber: true,
              ),

              _sectionHeader('💰 Budget & Stay'),
              _buildTextField(
                'Budget per person(LKR)',
                _budgetController,
                isNumber: true,
              ),
              _buildDropdown(
                'Accommodation',
                [
                  'Hotel',
                  'Resort',
                  'Airbnb',
                  'Hostel',
                  'Guesthouse',
                  'Camping',
                ],
                _selectedAccommodationType,
                (v) => setState(() => _selectedAccommodationType = v),
              ),

              _sectionHeader('🚗 Travel'),
              _buildTextField('Departure City', _departureCityController),
              _buildDropdown(
                'Transportation',
                ['Car/Road Trip', 'Train', 'Bus', 'Mixed'],
                _selectedTransportationMode,
                (v) => setState(() => _selectedTransportationMode = v),
              ),

              _sectionHeader('🎯 Activities'),
              _buildMultiLineField('Activities', _activitiesController),

              _sectionHeader('📞 Contact'),
              _buildTextField('Organizer Name', _organizerNameController),
              _buildTextField('Email', _emailController),
              _buildTextField('Phone', _phoneController),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Trip',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: orangeColor,
      ),
    ),
  );

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: orangeColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
    ),
  );

  Widget _buildMultiLineField(String label, TextEditingController controller) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: orangeColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      );

  Widget _buildDropdown(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: orangeColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Select $label', style: TextStyle(color: Colors.grey)),
        ),
        ...options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
      ],
      onChanged: onChanged,
      validator: (value) => value == null ? 'Required' : null,
    ),
  );

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: orangeColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    date != null
                        ? "${date.day}/${date.month}/${date.year}"
                        : "Select",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: date != null ? Colors.black87 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
