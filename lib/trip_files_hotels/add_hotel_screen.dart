import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:path/path.dart' as path;
import '../database/db_helper.dart';
import '../trip/trip_model.dart';
import 'hotel_model.dart' as hotel_model;

class AddHotelScreen extends StatefulWidget {
  final Trip trip;

  const AddHotelScreen({super.key, required this.trip});

  @override
  State<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
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
  
  // Fixed icon for hotels
  IconData _selectedIcon = Icons.hotel;
  
  // File attachments
  final List<Map<String, dynamic>> _selectedFiles = [];
  final Set<hotel_model.FileType> _selectedFileTypes = {};
  bool _isFileTypeSelectionMode = true;
  
  // Aliases for file picker types
  static const _typeImage = picker.FileType.image;
  static const _typeCustom = picker.FileType.custom;

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

  // Format day value to support ranges
  String _formatDayValue(String value) {
    value = value.trim().toLowerCase();
    // If input is just a number, format as "day X"
    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'day $value';
    }
    // If input has "to" for range, format as "day X to day Y"
    if (RegExp(r'^(\d+)\s*to\s*(\d+)$').hasMatch(value)) {
      var match = RegExp(r'^(\d+)\s*to\s*(\d+)$').firstMatch(value);
      if (match != null) {
        String start = match.group(1)!;
        String end = match.group(2)!;
        return 'day $start to day $end';
      }
    }
    // If input doesn't start with "day ", add it for single day
    if (!value.startsWith('day ')) {
      return 'day $value';
    }
    // Otherwise return as is
    return value;
  }

  // Submit form and save to database
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Generate a unique ID for the hotel
      String hotelId = const Uuid().v4();
      
      // Create file attachment objects
      final attachments = _selectedFiles.map((fileData) {
        return hotel_model.FileAttachment(
          fileType: fileData['fileType'],
          filePath: fileData['file'].path,
          fileName: fileData['fileName'],
        );
      }).toList();

      // Create a new hotel object
      hotel_model.Hotel newHotel = hotel_model.Hotel(
        id: hotelId,
        tripId: widget.trip.id,
        day: _formatDayValue(_dayController.text),
        time: _formatTimeValue(),
        activity: _activityController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        icon: _selectedIcon,
        attachments: attachments,
      );
      
      try {
        // Save to database
        await _dbHelper.insertHotel(newHotel);
        
        // Show success message and pop back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Hotel added successfully!',
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
                'Error adding hotel: ${e.toString()}',
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
          'Add Hotel',
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
                        Icons.hotel,
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
                
                // Day field with range support
                TextFormField(
                  controller: _dayController,
                  decoration: _buildInputDecoration(
                    'Day (e.g., 1, Day 1, or 1 to 3)',
                    Icons.calendar_today_outlined,
                    suffixIcon: const Tooltip(
                      message: 'Enter day number, day range (e.g., 1 to 3), or "Day X"',
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
                      return 'Please enter the day(s)';
                    }
                    return null;
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
                            'Check-in Time',
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
                            'Check-in & Check-out',
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
                
                // Time picker section
                Column(
                  children: [
                    // Start time field (Check-in time)
                    InkWell(
                      onTap: _selectStartTime,
                      borderRadius: BorderRadius.circular(10),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _startTimeController,
                          decoration: _buildInputDecoration(
                            _isTimeRangeMode ? 'Check-in Time' : 'Time',
                            Icons.access_time_outlined,
                            suffixIcon: Icon(
                              Icons.access_time,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return _isTimeRangeMode ? 'Please enter check-in time' : 'Please enter time';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    
                    // End time field (Check-out time - only visible in range mode)
                    if (_isTimeRangeMode) ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectEndTime,
                        borderRadius: BorderRadius.circular(10),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _endTimeController,
                            decoration: _buildInputDecoration(
                              'Check-out Time',
                              Icons.access_time_outlined,
                              suffixIcon: Icon(
                                Icons.access_time,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter check-out time';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildSectionTitle('Hotel Details'),
                const SizedBox(height: 16),
                
                // Hotel name field
                TextFormField(
                  controller: _activityController,
                  decoration: _buildInputDecoration('Hotel Name', Icons.hotel_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the hotel name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Location field
                TextFormField(
                  controller: _locationController,
                  decoration: _buildInputDecoration('Location/Address', Icons.location_on_outlined),
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
                  decoration: _buildInputDecoration('Notes/Description', Icons.description_outlined),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description or notes';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // File attachment section
                _buildSectionTitle('Attach Files (Optional)'),
                const SizedBox(height: 16),
                
                // File type selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File type title and count
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      children: [
                        Text(
                          _isFileTypeSelectionMode
                            ? 'Select File Type(s):'
                            : 'Selected File Type(s):',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_selectedFileTypes.isNotEmpty)
                          Chip(
                            label: Text(
                              '${_selectedFileTypes.length}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: const Color(0xFF48BB78),
                            padding: const EdgeInsets.all(0),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Action buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_isFileTypeSelectionMode)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.file_copy_outlined, size: 16),
                            label: Text(
                              'Pick Files',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF48BB78),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8
                              ),
                            ),
                            onPressed: _selectedFileTypes.isEmpty
                              ? null
                              : _pickFilesBasedOnSelectedTypes,
                          ),
                        if (!_isFileTypeSelectionMode)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                            label: Text(
                              'Back to Types',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF48BB78),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isFileTypeSelectionMode = true;
                              });
                            },
                          ),
                        if (_selectedFiles.isNotEmpty || _selectedFileTypes.isNotEmpty)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: Text(
                              'Clear All',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedFiles.clear();
                                _selectedFileTypes.clear();
                                _isFileTypeSelectionMode = true;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isFileTypeSelectionMode)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: Text(
                              'Image',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _selectedFileTypes.contains(hotel_model.FileType.image) ? Colors.white : const Color(0xFF718096),
                              ),
                            ),
                            selected: _selectedFileTypes.contains(hotel_model.FileType.image),
                            selectedColor: const Color(0xFF48BB78),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFileTypes.add(hotel_model.FileType.image);
                                } else {
                                  _selectedFileTypes.remove(hotel_model.FileType.image);
                                }
                              });
                            },
                          ),
                          FilterChip(
                            label: Text(
                              'PDF',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _selectedFileTypes.contains(hotel_model.FileType.pdf) ? Colors.white : const Color(0xFF718096),
                              ),
                            ),
                            selected: _selectedFileTypes.contains(hotel_model.FileType.pdf),
                            selectedColor: const Color(0xFF48BB78),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFileTypes.add(hotel_model.FileType.pdf);
                                } else {
                                  _selectedFileTypes.remove(hotel_model.FileType.pdf);
                                }
                              });
                            },
                          ),
                          FilterChip(
                            label: Text(
                              'DOCX',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _selectedFileTypes.contains(hotel_model.FileType.docx) ? Colors.white : const Color(0xFF718096),
                              ),
                            ),
                            selected: _selectedFileTypes.contains(hotel_model.FileType.docx),
                            selectedColor: const Color(0xFF48BB78),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFileTypes.add(hotel_model.FileType.docx);
                                } else {
                                  _selectedFileTypes.remove(hotel_model.FileType.docx);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                ),
                
                // Display selected files info
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Selected Files (${_selectedFiles.length}):',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final fileData = _selectedFiles[index];
                      final File file = fileData['file'];
                      final String fileName = fileData['fileName'];
                      final hotel_model.FileType fileType = fileData['fileType'];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF48BB78).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF48BB78).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getFileTypeIcon(fileName),
                                color: const Color(0xFF48BB78),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fileName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${(file.lengthSync() / 1024).toStringAsFixed(2)} KB',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              color: Colors.grey.shade600,
                              onPressed: () {
                                setState(() {
                                  _selectedFiles.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                
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
                      'Add Hotel',
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
  
  // Pick files based on selected file types
  Future<void> _pickFilesBasedOnSelectedTypes() async {
    if (_selectedFileTypes.isEmpty) return;
    
    setState(() {
      _isFileTypeSelectionMode = false;
    });
    
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Opening file picker...',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );

      int totalFilesSelected = 0;
      
      // Handle image files
      if (_selectedFileTypes.contains(hotel_model.FileType.image)) {
        picker.FilePickerResult? imageResult = await picker.FilePicker.platform.pickFiles(
          type: picker.FileType.image,
          allowMultiple: true,
        );
        
        if (imageResult != null && imageResult.files.isNotEmpty) {
          totalFilesSelected += imageResult.files.length;
          _processFiles(imageResult.files);
        }
      }
      
      // Handle PDF files
      if (_selectedFileTypes.contains(hotel_model.FileType.pdf)) {
        picker.FilePickerResult? pdfResult = await picker.FilePicker.platform.pickFiles(
          type: picker.FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: true,
        );
        
        if (pdfResult != null && pdfResult.files.isNotEmpty) {
          totalFilesSelected += pdfResult.files.length;
          _processFiles(pdfResult.files);
        }
      }
      
      // Handle DOCX files
      if (_selectedFileTypes.contains(hotel_model.FileType.docx)) {
        picker.FilePickerResult? docxResult = await picker.FilePicker.platform.pickFiles(
          type: picker.FileType.custom,
          allowedExtensions: ['docx'],
          allowMultiple: true,
        );
        
        if (docxResult != null && docxResult.files.isNotEmpty) {
          totalFilesSelected += docxResult.files.length;
          _processFiles(docxResult.files);
        }
      }
      
      // Show success message if any files were selected
      if (totalFilesSelected > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$totalFilesSelected file(s) selected',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No files selected',
              style: GoogleFonts.poppins(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error picking files: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error selecting files: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  // Process selected files and add them to the list
  void _processFiles(List<picker.PlatformFile> files) {
    for (var platformFile in files) {
      if (platformFile.path != null) {
        File file = File(platformFile.path!);
        String fileName = path.basename(file.path);
        
        // Determine file type based on extension
        hotel_model.FileType fileType;
        if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg') ||
            fileName.endsWith('.png') || fileName.endsWith('.gif')) {
          fileType = hotel_model.FileType.image;
        } else if (fileName.endsWith('.pdf')) {
          fileType = hotel_model.FileType.pdf;
        } else if (fileName.endsWith('.docx')) {
          fileType = hotel_model.FileType.docx;
        } else {
          // Default to image type if can't determine
          fileType = hotel_model.FileType.image;
        }
        
        // Add to selected files list
        setState(() {
          _selectedFiles.add({
            'file': file,
            'fileName': fileName,
            'fileType': fileType,
          });
        });
      }
    }
  }
  
  // Helper method to get icon based on file type
  IconData _getFileTypeIcon(String fileName) {
    if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif')) {
      return Icons.image_outlined;
    } else if (fileName.endsWith('.pdf')) {
      return Icons.picture_as_pdf_outlined;
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return Icons.description_outlined;
    } else {
      return Icons.insert_drive_file_outlined;
    }
  }
}