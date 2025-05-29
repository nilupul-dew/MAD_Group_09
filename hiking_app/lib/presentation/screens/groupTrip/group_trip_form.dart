import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupTripForm extends StatefulWidget {
  final String? tripId;
  final Map<String, dynamic>? initialData;

  const GroupTripForm({Key? key, this.tripId, this.initialData})
    : super(key: key);

  @override
  State<GroupTripForm> createState() => _GroupTripFormState();
}

class _GroupTripFormState extends State<GroupTripForm> {
  final _formKey = GlobalKey<FormState>();
  final orangeColor = const Color(0xFFE3641F);

  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _travellersController = TextEditingController();
  final _budgetController = TextEditingController();
  final _departureCityController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedTripType;
  String? _selectedAccommodationType;
  String? _selectedTransportationMode;
  DateTime? _startDate;
  DateTime? _endDate;
  int _duration = 0;
  bool _isLoading = false;

  Map<String, dynamic>? editingTripData;
  String? editingTripId;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Handle initial data from constructor
    if (widget.initialData != null) {
      _loadInitialData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the arguments passed from the edit button
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      editingTripData = args['tripData'];
      editingTripId = args['tripId'];
      isEditing = args['isEditing'] ?? false;

      // Pre-populate your form fields with the existing data
      if (isEditing && editingTripData != null) {
        _populateFormFields();
      }
    } else if (widget.initialData != null && !isEditing) {
      isEditing = widget.tripId != null;
      editingTripId = widget.tripId;
      editingTripData = widget.initialData;
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    final data = widget.initialData!;
    _tripNameController.text = data['title'] ?? '';
    _destinationController.text = data['destination'] ?? '';
    _selectedTripType = data['tripType'];
    _startDate = (data['startDate'] as Timestamp?)?.toDate();
    _endDate = (data['endDate'] as Timestamp?)?.toDate();
    _travellersController.text = data['maxMembers']?.toString() ?? '';
    _budgetController.text = data['budget']?.toString() ?? '';
    _selectedAccommodationType = data['accommodationType'];
    _departureCityController.text = data['departureCity'] ?? '';
    _selectedTransportationMode = data['transportationMode'];
    _activitiesController.text = data['activities'] ?? '';
    _emailController.text = data['organizerEmail'] ?? '';
    _phoneController.text = data['organizerPhone'] ?? '';
    _calculateDuration();
  }

  void _populateFormFields() {
    //  population method using route arguments
    _tripNameController.text = editingTripData!['title'] ?? '';
    _destinationController.text = editingTripData!['destination'] ?? '';
    _budgetController.text = editingTripData!['budget']?.toString() ?? '';
    _activitiesController.text = editingTripData!['activities'] ?? '';
    _travellersController.text =
        editingTripData!['maxMembers']?.toString() ?? '';
    _departureCityController.text = editingTripData!['departureCity'] ?? '';
    _emailController.text = editingTripData!['organizerEmail'] ?? '';
    _phoneController.text = editingTripData!['organizerPhone'] ?? '';

    // Set dropdown values
    _selectedTripType = editingTripData!['tripType'];
    _selectedAccommodationType = editingTripData!['accommodationType'];
    _selectedTransportationMode = editingTripData!['transportationMode'];

    // For dates, convert Timestamps back to DateTime
    if (editingTripData!['startDate'] != null) {
      _startDate = (editingTripData!['startDate'] as Timestamp).toDate();
    }
    if (editingTripData!['endDate'] != null) {
      _endDate = (editingTripData!['endDate'] as Timestamp).toDate();
    }

    _calculateDuration();
    setState(() {}); // Refresh the UI
  }

  @override
  void dispose() {
    [
      _tripNameController,
      _destinationController,
      _travellersController,
      _budgetController,
      _departureCityController,
      _activitiesController,
      _emailController,
      _phoneController,
    ].forEach((c) => c.dispose());
    super.dispose();
  }

  void _calculateDuration() {
    if (_startDate != null && _endDate != null) {
      _duration = _endDate!.difference(_startDate!).inDays + 1;
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? _startDate ?? DateTime.now()
              : _endDate ?? _startDate ?? DateTime.now(),
      firstDate: isStart ? DateTime.now() : _startDate ?? DateTime.now(),
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
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? 'testUser123';
    final tripData = {
      'title': _tripNameController.text,
      'destination': _destinationController.text,
      'tripType': _selectedTripType,
      'startDate': _startDate,
      'endDate': _endDate,
      'duration': _duration,
      'maxMembers': int.parse(_travellersController.text),
      'budget': double.parse(_budgetController.text),
      'accommodationType': _selectedAccommodationType,
      'departureCity': _departureCityController.text,
      'transportationMode': _selectedTransportationMode,
      'activities': _activitiesController.text,
      'organizerEmail': _emailController.text,
      'organizerPhone': _phoneController.text,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      //  editing logic - check multiple sources for trip ID
      final tripIdToUpdate = editingTripId ?? widget.tripId;

      if ((isEditing && editingTripId != null) || widget.tripId != null) {
        // Update existing document
        await FirebaseFirestore.instance
            .collection('group_trips')
            .doc(tripIdToUpdate)
            .update(tripData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Create new document
        tripData.addAll({
          'createdBy': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'members': [uid],
          'memberCount': 1,
          'status': 'active',
        });
        await FirebaseFirestore.instance
            .collection('group_trips')
            .add(tripData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: orangeColor,
        title: Text(
          (isEditing || widget.tripId != null) ? 'Edit Trip' : 'Create Trip',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Trip Details'),
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
                  _buildDateSection(),
                  _buildTextField(
                    'Max Travelers',
                    _travellersController,
                    isNumber: true,
                  ),
                  _sectionHeader('Budget & Stay'),
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
                  _sectionHeader('Travel'),
                  _buildTextField('Departure City', _departureCityController),
                  _buildDropdown(
                    'Transportation',
                    ['Car/Road Trip', 'Train', 'Bus', 'Mixed'],
                    _selectedTransportationMode,
                    (v) => setState(() => _selectedTransportationMode = v),
                  ),
                  _sectionHeader('Activities'),
                  _buildMultiLineField('Activities', _activitiesController),
                  _sectionHeader('Contact'),
                  _buildTextField('Email', _emailController),
                  _buildTextField('Phone', _phoneController),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
  }

  Widget _buildMultiLineField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
          DropdownMenuItem(
            value: null,
            child: Text('Select $label', style: TextStyle(color: Colors.grey)),
          ),
          ...options.map(
            (opt) => DropdownMenuItem(value: opt, child: Text(opt)),
          ),
        ],
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                  Icon(Icons.access_time, color: orangeColor, size: 20),
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
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
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
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: orangeColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          (isEditing || widget.tripId != null) ? 'Save Changes' : 'Create Trip',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
