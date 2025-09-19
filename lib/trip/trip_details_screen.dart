import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        onPressed: () => _showAddDialog(context),
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

  Widget _buildItineraryTab() {
    // Sample itinerary items based on trip destination
    final sampleItinerary = [
      {
        'day': 'Day 1',
        'time': '9:00 AM - 12:00 PM',
        'activity': 'Arrival & City Tour',
        'location': 'Airport to City Center',
        'icon': Icons.flight_land_outlined,
        'description': 'Arrive at the airport and take a guided tour of the historic city center.',
      },
      {
        'day': 'Day 2',
        'time': '10:00 AM - 4:00 PM',
        'activity': 'Museum Visit',
        'location': 'National Museum',
        'icon': Icons.museum_outlined,
        'description': 'Explore the rich history and culture at the National Museum. Entry fee included.',
      },
      {
        'day': 'Day 3',
        'time': '8:00 AM - 6:00 PM',
        'activity': 'Beach Day',
        'location': 'Sunny Beach',
        'icon': Icons.beach_access_outlined,
        'description': 'Relax at the beautiful beach with water sports and local cuisine.',
      },
    ];

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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: sampleItinerary.length,
            itemBuilder: (context, index) {
              final item = sampleItinerary[index];
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
                              item['icon'] as IconData,
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
                                  item['activity'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['location'] as String,
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
                              item['day'] as String,
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
                      Text(
                        item['time'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF48BB78),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['description'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF4A5568),
                          height: 1.4,
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
}