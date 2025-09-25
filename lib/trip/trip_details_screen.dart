import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/db_helper.dart';
import '../trip_files_itinerary/itinerary_model.dart';
import '../trip_files_itinerary/add_itinerary_screen.dart';
import '../trip_files_itinerary/edit_itinerary_screen.dart';
import '../text/expandable_text.dart';
import 'trip_model.dart';

// Trip details screen with tabs for each feature
class TripDetailsScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Itinerary> _itineraries = [];
  bool _isLoading = true;

  final List<String> _tabNames = [
    "Itinerary",
    "Hotels",
    "Flights",
    "Documents",
    "Expenses",
    "Memories"
  ];

  final List<IconData> _tabIcons = [
    Icons.map_outlined,
    Icons.hotel_outlined,
    Icons.flight_outlined,
    Icons.folder_outlined,
    Icons.receipt_long_outlined,
    Icons.camera_alt_outlined,
  ];

  final List<Color> _tabColors = [
    Color(0xFF48BB78), // Green
    Color(0xFF4299E1), // Blue
    Color(0xFF9F7AEA), // Purple
    Color(0xFFED8936), // Orange
    Color(0xFFE53E3E), // Red
    Color(0xFF38B2AC), // Teal
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
    
    // Load itineraries from database
    _loadItineraries();
  }
  
  // Load itineraries for this trip
  Future<void> _loadItineraries() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final itineraries = await _dbHelper.getItinerariesForTrip(widget.trip.id);
      if (mounted) {
        setState(() {
          _itineraries = itineraries;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading itineraries: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.trip.country,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Trip Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.trip.destination,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.trip.dates,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.trip.daysLeft > 0 ? "${widget.trip.daysLeft} days left" : "Active Trip",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // TabBar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF667eea),
              labelColor: const Color(0xFF2D3748),
              unselectedLabelColor: const Color(0xFF718096),
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
              tabs: [
                Tab(
                  icon: const Icon(Icons.map_outlined, size: 20),
                  text: "Itinerary",
                ),
                Tab(
                  icon: const Icon(Icons.hotel_outlined, size: 20),
                  text: "Hotels",
                ),
                Tab(
                  icon: const Icon(Icons.flight_outlined, size: 20),
                  text: "Flights",
                ),
                Tab(
                  icon: const Icon(Icons.folder_outlined, size: 20),
                  text: "Documents",
                ),
                Tab(
                  icon: const Icon(Icons.receipt_long_outlined, size: 20),
                  text: "Expenses",
                ),
                Tab(
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  text: "Memories",
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItineraryTab(),
                _buildPlaceholderTab("Hotels", "No hotel bookings added yet", Icons.hotel_outlined),
                _buildPlaceholderTab("Flights", "No flight information added yet", Icons.flight_outlined),
                _buildPlaceholderTab("Documents", "No documents uploaded yet", Icons.folder_outlined),
                _buildPlaceholderTab("Expenses", "No expenses tracked yet", Icons.receipt_long_outlined),
                _buildPlaceholderTab("Memories", "No memories captured yet", Icons.camera_alt_outlined),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_currentIndex == 0) {
            _navigateToAddItineraryScreen();
          } else {
            _showAddDialog(context);
          }
        },
        backgroundColor: _tabColors[_currentIndex],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          "Add ${_tabNames[_currentIndex]}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _navigateToAddItineraryScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItineraryScreen(trip: widget.trip),
      ),
    );
    
    // Refresh itineraries if a new one was added
    if (result == true) {
      _loadItineraries();
    }
  }
  
  // Navigate to edit itinerary screen
  Future<void> _navigateToEditItineraryScreen(Itinerary itinerary) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItineraryScreen(
          trip: widget.trip,
          itinerary: itinerary,
        ),
      ),
    );
    
    // Refresh itineraries if an item was edited
    if (result == true) {
      _loadItineraries();
    }
  }
  
  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(Itinerary itinerary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Itinerary',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this itinerary item?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    itinerary.icon,
                    size: 20,
                    color: const Color(0xFF667eea),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itinerary.activity,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          '${itinerary.day}, ${itinerary.time}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Delete the itinerary item
              try {
                await _dbHelper.deleteItinerary(itinerary.id);
                
                if (mounted) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Itinerary deleted successfully',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  // Close dialog and refresh
                  Navigator.pop(context);
                  _loadItineraries();
                }
              } catch (e) {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error deleting itinerary: ${e.toString()}',
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
                  Navigator.pop(context);
                }
              }
            },
            icon: const Icon(Icons.delete, size: 18),
            label: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build expandable description text
  Widget _buildExpandableDescription(String description) {
    // Use our reusable ExpandableText widget
    return ExpandableText(
      text: description,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF4A5568),
        height: 1.4,
      ),
      maxLines: 3,
    );
  }

  Widget _buildItineraryTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF667eea),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                Icons.map_outlined,
                color: const Color(0xFF667eea),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Trip Itinerary',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _itineraries.isEmpty
              ? _buildEmptyItineraryState()
              : ListView.builder(
                  // Add bottom padding to prevent overlap with the FAB
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 90
                  ),
                  itemCount: _itineraries.length,
                  itemBuilder: (context, index) {
                    final itinerary = _itineraries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              itinerary.icon,
                              color: const Color(0xFF667eea),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itinerary.activity,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  itinerary.location,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              itinerary.day,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF718096),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Time info
                      Text(
                        itinerary.time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF48BB78),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Expandable description
                      _buildExpandableDescription(itinerary.description),

                      // File attachments display (if any)
                      if (itinerary.hasAttachments) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Attachments (${itinerary.attachments.length}):',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: itinerary.attachments.map((attachment) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => _openAttachment(attachment),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF667eea).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF667eea).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: _getFileTypeIconForAttachment(attachment),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              attachment.fileName,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              _getAttachmentTypeText(attachment.fileType),
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.open_in_new,
                                        size: 20,
                                        color: Color(0xFF667eea),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      
                      // Single settings menu button at bottom
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.settings,
                            color: Color(0xFF718096),
                            size: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 4,
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToEditItineraryScreen(itinerary);
                            } else if (value == 'delete') {
                              _showDeleteConfirmationDialog(itinerary);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(
                                leading: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF667eea),
                                  size: 20,
                                ),
                                title: Text(
                                  'Edit',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFE53E3E),
                                  size: 20,
                                ),
                                title: Text(
                                  'Delete',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyItineraryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF667eea).withOpacity(0.1),
              ),
            ),
            child: const Icon(
              Icons.map_outlined,
              size: 56,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Itinerary',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No itinerary items added yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            "Tap the + button to add your first itinerary item",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF667eea).withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              size: 56,
              color: const Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            "Tap the + button to add your first item",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    String currentSection = _tabNames[_currentIndex];
    IconData currentIcon = _tabIcons[_currentIndex];
    Color currentColor = _tabColors[_currentIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                currentIcon,
                color: currentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Add $currentSection",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getAddDescription(currentSection),
              style: GoogleFonts.poppins(
                color: const Color(0xFF718096),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: currentColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: currentColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: currentColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Backend functionality would be implemented here.",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: currentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessSnackBar(currentSection, currentColor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: currentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              "Add",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getAddDescription(String section) {
    switch (section) {
      case "Itinerary":
        return "Add a new activity, location, or event to your trip itinerary. Include time, location, and notes.";
      case "Hotels":
        return "Add hotel booking details including dates, reservation number, and contact information.";
      case "Flights":
        return "Add flight information including departure/arrival times, flight numbers, and seat details.";
      case "Documents":
        return "Upload important travel documents like tickets, passports, or confirmations.";
      case "Expenses":
        return "Track a new expense with amount, category, and description for budget monitoring.";
      case "Memories":
        return "Add photos, videos, or notes to capture special moments from your trip.";
      default:
        return "Add a new item to this section of your trip.";
    }
  }

  void _showSuccessSnackBar(String section, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Added to $section (Frontend only)",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Helper method to get icon based on file attachment type
  Widget _getFileTypeIconForAttachment(FileAttachment attachment) {
    IconData iconData;
    
    switch (attachment.fileType) {
      case FileType.image:
        iconData = Icons.image_outlined;
        break;
      case FileType.pdf:
        iconData = Icons.picture_as_pdf_outlined;
        break;
      case FileType.docx:
        iconData = Icons.description_outlined;
        break;
      default:
        iconData = Icons.insert_drive_file_outlined;
    }
    
    return Icon(
      iconData,
      color: const Color(0xFF667eea),
      size: 24,
    );
  }
  
  // Helper method to get text description for file type
  String _getAttachmentTypeText(FileType fileType) {
    switch (fileType) {
      case FileType.image:
        return 'Image';
      case FileType.pdf:
        return 'PDF Document';
      case FileType.docx:
        return 'Word Document';
      default:
        return 'File Attachment';
    }
  }
  
  // Open an attachment
  void _openAttachment(FileAttachment attachment) async {
    try {
      final file = File(attachment.filePath);
      if (await file.exists()) {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Opening file...',
              style: GoogleFonts.poppins(),
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
        
        // Handle different file types appropriately
        if (attachment.fileType == FileType.image) {
          // For images, open in a dialog with a full-screen option
          _showImagePreview(file, attachment.fileName);
        } else {
          // For other file types, use URL launcher
          final Uri fileUri = Uri.file(file.path);
          try {
            final success = await launchUrl(fileUri);
            if (!success) {
              throw Exception('Could not launch file');
            }
          } catch (e) {
            throw Exception('Could not launch file: $e');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File not found: ${attachment.filePath}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error opening file: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
  
  // Show image preview dialog
  void _showImagePreview(File imageFile, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        fileName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image, size: 48, color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Could not load image',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}