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
        title: Text(widget.trip.country, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF667eea),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelStyle: GoogleFonts.poppins(fontSize: 12),
              tabs: [
                Tab(text: "Itinerary", icon: Icon(Icons.map_outlined, size: 20)),
                Tab(text: "Hotels", icon: Icon(Icons.hotel_outlined, size: 20)),
                Tab(text: "Flights", icon: Icon(Icons.flight_outlined, size: 20)),
                Tab(text: "Documents", icon: Icon(Icons.folder_outlined, size: 20)),
                Tab(text: "Expenses", icon: Icon(Icons.receipt_long_outlined, size: 20)),
                Tab(text: "Memories", icon: Icon(Icons.camera_alt_outlined, size: 20)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent("Itinerary planning will go here", Icons.map_outlined),
                _buildTabContent("Hotel bookings will go here", Icons.hotel_outlined),
                _buildTabContent("Flight information will go here", Icons.flight_outlined),
                _buildTabContent("Document storage will go here", Icons.folder_outlined),
                _buildTabContent("Expense tracking will go here", Icons.receipt_long_outlined),
                _buildTabContent("Photo memories will go here", Icons.camera_alt_outlined),
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

  Widget _buildTabContent(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _tabColors[_currentIndex].withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 48,
              color: _tabColors[_currentIndex],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
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