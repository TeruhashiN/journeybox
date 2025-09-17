import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../trip/trip_model.dart';
import '../trip/trips_section.dart';
import '../trip/add_trip_screen.dart'; // Add this import
import '../database/db_helper.dart';

class HomeScreen extends StatefulWidget { // Change to StatefulWidget
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  // Move trips to state so we can update them
  List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    print('Loading trips on init...');
    final loadedTrips = await dbHelper.getAllTrips();
    setState(() {
      trips = loadedTrips;
    });
    print('Set trips count: ${trips.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Header Section
              _buildHeader(context),

              const SizedBox(height: 28),

              // Stats Cards Row
              _buildStatsSection(trips),

              const SizedBox(height: 28),

              // Trips List Section
              Expanded(
                child: TripsSection(trips: trips),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateToAddTrip(context);
        },
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          "New Trip",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.luggage,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "JourneyBox",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Your journey, perfectly organized",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(List<Trip> trips) {
    final activeTrips = trips.where((trip) => trip.isActive).length;
    final totalCountries = trips.map((trip) => trip.country).toSet().length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard("$activeTrips", "Active Trips", Icons.flight_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard("23", "Documents", Icons.description_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard("$totalCountries", "Countries", Icons.public_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddTrip(BuildContext context) async {
    print('Navigating to add trip...');
    final Trip? newTrip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTripScreen(),
      ),
    );
  
    // If a new trip was created, add it to the list
    if (newTrip != null) {
      print('New trip returned: ${newTrip.destination}');
      setState(() {
        trips.insert(0, newTrip); // Add to beginning of list
      });
      print('Inserting to DB...');
      try {
        await dbHelper.insertTrip(newTrip);
        print('DB insert completed successfully');
      } catch (e) {
        print('DB insert error: $e');
        // Optionally remove from list if insert fails
        setState(() {
          trips.remove(newTrip);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save trip: $e')),
        );
      }
    }
  }
}