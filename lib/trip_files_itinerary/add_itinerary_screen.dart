import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../database/db_helper.dart';
import '../trip/trip_model.dart';
import 'itinerary_model.dart';

class AddItineraryScreen extends StatefulWidget {
  final Trip trip;

  const AddItineraryScreen({super.key, required this.trip});

  @override
  State<AddItineraryScreen> createState() => _AddItineraryScreenState();
}

class _AddItineraryScreenState extends State<AddItineraryScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Form controllers
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Time selection mode
  bool _isTimeRangeMode = false;
  
  // Selected icon
  IconData _selectedIcon = Icons.map_outlined;
  
  // Available icons for selection
  final List<MapEntry<String, IconData>> _availableIcons = [
    MapEntry('Map', Icons.map_outlined),
    MapEntry('Museum', Icons.museum_outlined),
    MapEntry('Beach', Icons.beach_access_outlined),
    MapEntry('Restaurant', Icons.restaurant_outlined),
    MapEntry('Hiking', Icons.hiking_outlined),
    MapEntry('Shopping', Icons.shopping_bag_outlined),
    MapEntry('Sightseeing', Icons.visibility_outlined),
    MapEntry('Tour', Icons.tour_outlined),
    MapEntry('Transport', Icons.directions_bus_outlined),
    MapEntry('Event', Icons.event_outlined),
    MapEntry('Activity', Icons.emoji_events_outlined),
  ];

  @override
  void dispose() {
    _dayController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _activityController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Format day value
  String _formatDayValue(String value) {
    // If input is just a number, format as "Day X"
    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Day $value';
    }
    // If input doesn't start with "Day ", add it
    if (!value.toLowerCase().trimLeft().startsWith('day ')) {
      return 'Day $value';
    }
    // Otherwise return as is
    return value;
  }

  // Submit form and save to database
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Generate a unique ID for the itinerary
      String itineraryId = const Uuid().v4();
      
      // Create a new itinerary object
      Itinerary newItinerary = Itinerary(
        id: itineraryId,
        tripId: widget.trip.id,
        day: _formatDayValue(_dayController.text),
        time: _formatTimeValue(),
        activity: _activityController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        icon: _selectedIcon,
      );
      
      try {
        // Save to database
        await _dbHelper.insertItinerary(newItinerary);
        
        // Show success message and pop back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Itinerary added successfully!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error adding itinerary: ${e.toString()}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  // Format time value based on mode
  String _formatTimeValue() {
    if (_isTimeRangeMode) {
      if (_startTimeController.text.isNotEmpty && _endTimeController.text.isNotEmpty) {
        return '${_startTimeController.text} - ${_endTimeController.text}';
      } else {
        return _startTimeController.text;
      }
    } else {
      return _startTimeController.text;
    }
  }

  // Show start time picker
  Future<void> _selectStartTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      // Convert to string format
      final String formattedTime = '${pickedTime.format(context)}';
      setState(() {
        _startTimeController.text = formattedTime;
      });
    }
  }
  
  // Show end time picker
  Future<void> _selectEndTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      // Convert to string format
      final String formattedTime = '${pickedTime.format(context)}';
      setState(() {
        _endTimeController.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Itinerary',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF48BB78),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip info header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF48BB78),
                        const Color(0xFF38A169),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.trip.destination,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.trip.dates,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Form fields
                _buildSectionTitle('Day Information'),
                const SizedBox(height: 16),
                
                // Day field
                TextFormField(
                  controller: _dayController,
                  decoration: _buildInputDecoration(
                    'Day (e.g., 1 or Day 1)',
                    Icons.calendar_today_outlined,
                    suffixIcon: const Tooltip(
                      message: 'Enter just a number or "Day X"',
                      child: Icon(
                        Icons.info_outline,
                        color: Color(0xFF48BB78),
                        size: 20,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the day';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // If user enters just a number, show hint that it will be formatted
                    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                      // Optional: could show a hint that this will appear as "Day X"
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Time selection mode toggle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Input Mode:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(
                            'Single Time',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: !_isTimeRangeMode ? Colors.white : const Color(0xFF718096),
                            ),
                          ),
                          selected: !_isTimeRangeMode,
                          selectedColor: const Color(0xFF48BB78),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _isTimeRangeMode = false;
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text(
                            'Time Range',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _isTimeRangeMode ? Colors.white : const Color(0xFF718096),
                            ),
                          ),
                          selected: _isTimeRangeMode,
                          selectedColor: const Color(0xFF48BB78),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _isTimeRangeMode = true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Time picker section with responsive layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        // Start time field
                        InkWell(
                          onTap: _selectStartTime,
                          borderRadius: BorderRadius.circular(10),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _startTimeController,
                              decoration: _buildInputDecoration(
                                _isTimeRangeMode ? 'Start Time' : 'Time',
                                Icons.access_time_outlined,
                                suffixIcon: Icon(
                                  Icons.access_time,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _isTimeRangeMode ? 'Please enter start time' : 'Please enter time';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        
                        // End time field (only visible in range mode)
                        if (_isTimeRangeMode) ...[
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _selectEndTime,
                            borderRadius: BorderRadius.circular(10),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _endTimeController,
                                decoration: _buildInputDecoration(
                                  'End Time',
                                  Icons.access_time_outlined,
                                  suffixIcon: Icon(
                                    Icons.access_time,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter end time';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                _buildSectionTitle('Activity Details'),
                const SizedBox(height: 16),
                
                // Activity field
                TextFormField(
                  controller: _activityController,
                  decoration: _buildInputDecoration('Activity Name', Icons.local_activity_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the activity name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Location field
                TextFormField(
                  controller: _locationController,
                  decoration: _buildInputDecoration('Location', Icons.location_on_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: _buildInputDecoration('Description', Icons.description_outlined),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                _buildSectionTitle('Choose Icon'),
                const SizedBox(height: 16),
                
                // Icon selection grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final iconEntry = _availableIcons[index];
                    final bool isSelected = _selectedIcon == iconEntry.value;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconEntry.value;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF48BB78).withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF48BB78)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Tooltip(
                          message: iconEntry.key,
                          child: Icon(
                            iconEntry.value,
                            color: isSelected
                                ? const Color(0xFF48BB78)
                                : const Color(0xFF718096),
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48BB78),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Add Itinerary',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3748),
      ),
    );
  }

  // Helper to build consistent input decoration
  InputDecoration _buildInputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: const Color(0xFF718096),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF48BB78),
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF48BB78),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
    );
  }
}