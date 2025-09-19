import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trip_model.dart';
import 'trip_details_screen.dart';
import 'edit_trip_screen.dart';
import '../database/db_helper.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onRefresh;

  const TripCard({super.key, required this.trip, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = trip.daysLeft > 0;
    final isPast = trip.daysLeft < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _navigateToTripDetails(context, trip);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCountryFlag(trip.country),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.country,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              trip.destination,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? const Color(0xFF48BB78).withOpacity(0.1)
                              : isPast
                              ? const Color(0xFF718096).withOpacity(0.1)
                              : const Color(0xFF4299E1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isUpcoming
                              ? "${trip.daysLeft} days left"
                              : isPast
                              ? "Finished"
                              : "Active",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isUpcoming
                                ? const Color(0xFF48BB78)
                                : isPast
                                ? const Color(0xFF718096)
                                : const Color(0xFF4299E1),
                          ),
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editTrip(context);
                          } else if (value == 'delete') {
                            _deleteTrip(context);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        icon: const Icon(Icons.more_vert, color: Color(0xFF718096)),
                        tooltip: 'Trip actions',
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Trip Dates
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trip.dates,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAction(Icons.map_outlined, "Itinerary"),
                  _buildQuickAction(Icons.hotel_outlined, "Hotels"),
                  _buildQuickAction(Icons.flight_outlined, "Flights"),
                  _buildQuickAction(Icons.receipt_long_outlined, "Expenses"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF667eea),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  String _getCountryFlag(String country) {
    final Map<String, String> flags = {
      'Afghanistan': '🇦🇫',
      'Albania': '🇦🇱',
      'Algeria': '🇩🇿',
      'Andorra': '🇦🇩',
      'Angola': '🇦🇴',
      'Argentina': '🇦🇷',
      'Armenia': '🇦🇲',
      'Australia': '🇦🇺',
      'Austria': '🇦🇹',
      'Azerbaijan': '🇦🇿',
      'Bahamas': '🇧🇸',
      'Bahrain': '🇧🇭',
      'Bangladesh': '🇧🇩',
      'Belgium': '🇧🇪',
      'Bhutan': '🇧🇹',
      'Bolivia': '🇧🇴',
      'Bosnia and Herzegovina': '🇧🇦',
      'Botswana': '🇧🇼',
      'Brazil': '🇧🇷',
      'Brunei': '🇧🇳',
      'Bulgaria': '🇧🇬',
      'Cambodia': '🇰🇭',
      'Cameroon': '🇨🇲',
      'Canada': '🇨🇦',
      'Chile': '🇨🇱',
      'China': '🇨🇳',
      'Colombia': '🇨🇴',
      'Costa Rica': '🇨🇷',
      'Croatia': '🇭🇷',
      'Cuba': '🇨🇺',
      'Cyprus': '🇨🇾',
      'Czech Republic': '🇨🇿',
      'Denmark': '🇩🇰',
      'Dominican Republic': '🇩🇴',
      'Ecuador': '🇪🇨',
      'Egypt': '🇪🇬',
      'El Salvador': '🇸🇻',
      'Estonia': '🇪🇪',
      'Ethiopia': '🇪🇹',
      'Fiji': '🇫🇯',
      'Finland': '🇫🇮',
      'France': '🇫🇷',
      'Germany': '🇩🇪',
      'Greece': '🇬🇷',
      'Guatemala': '🇬🇹',
      'Honduras': '🇭🇳',
      'Hong Kong': '🇭🇰',
      'Hungary': '🇭🇺',
      'Iceland': '🇮🇸',
      'India': '🇮🇳',
      'Indonesia': '🇮🇩',
      'Iran': '🇮🇷',
      'Iraq': '🇮🇶',
      'Ireland': '🇮🇪',
      'Israel': '🇮🇱',
      'Italy': '🇮🇹',
      'Jamaica': '🇯🇲',
      'Japan': '🇯🇵',
      'Jordan': '🇯🇴',
      'Kazakhstan': '🇰🇿',
      'Kenya': '🇰🇪',
      'Kuwait': '🇰🇼',
      'Kyrgyzstan': '🇰🇬',
      'Laos': '🇱🇦',
      'Latvia': '🇱🇻',
      'Lebanon': '🇱🇧',
      'Libya': '🇱🇾',
      'Lithuania': '🇱🇹',
      'Luxembourg': '🇱🇺',
      'Macau': '🇲🇴',
      'Madagascar': '🇲🇬',
      'Malaysia': '🇲🇾',
      'Maldives': '🇲🇻',
      'Mali': '🇲🇱',
      'Malta': '🇲🇹',
      'Mexico': '🇲🇽',
      'Moldova': '🇲🇩',
      'Monaco': '🇲🇨',
      'Mongolia': '🇲🇳',
      'Montenegro': '🇲🇪',
      'Morocco': '🇲🇦',
      'Myanmar': '🇲🇲',
      'Nepal': '🇳🇵',
      'Netherlands': '🇳🇱',
      'New Zealand': '🇳🇿',
      'Nicaragua': '🇳🇮',
      'Nigeria': '🇳🇬',
      'North Korea': '🇰🇵',
      'North Macedonia': '🇲🇰',
      'Norway': '🇳🇴',
      'Oman': '🇴🇲',
      'Pakistan': '🇵🇰',
      'Panama': '🇵🇦',
      'Paraguay': '🇵🇾',
      'Peru': '🇵🇪',
      'Philippines': '🇵🇭',
      'Poland': '🇵🇱',
      'Portugal': '🇵🇹',
      'Puerto Rico': '🇵🇷',
      'Qatar': '🇶🇦',
      'Romania': '🇷🇴',
      'Russia': '🇷🇺',
      'Rwanda': '🇷🇼',
      'Saudi Arabia': '🇸🇦',
      'Serbia': '🇷🇸',
      'Singapore': '🇸🇬',
      'Slovakia': '🇸🇰',
      'Slovenia': '🇸🇮',
      'South Africa': '🇿🇦',
      'South Korea': '🇰🇷',
      'Spain': '🇪🇸',
      'Sri Lanka': '🇱🇰',
      'Sudan': '🇸🇩',
      'Sweden': '🇸🇪',
      'Switzerland': '🇨🇭',
      'Syria': '🇸🇾',
      'Taiwan': '🇹🇼',
      'Tajikistan': '🇹🇯',
      'Tanzania': '🇹🇿',
      'Thailand': '🇹🇭',
      'Tunisia': '🇹🇳',
      'Turkey': '🇹🇷',
      'Turkmenistan': '🇹🇲',
      'Uganda': '🇺🇬',
      'Ukraine': '🇺🇦',
      'United Arab Emirates': '🇦🇪',
      'United Kingdom': '🇬🇧',
      'United States': '🇺🇸',
      'Uruguay': '🇺🇾',
      'Uzbekistan': '🇺🇿',
      'Venezuela': '🇻🇪',
      'Vietnam': '🇻🇳',
      'Yemen': '🇾🇪',
      'Zambia': '🇿🇲',
      'Zimbabwe': '🇿🇼',
    };

    return flags[country] ?? '🌍';
  }


  void _navigateToTripDetails(BuildContext context, Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(trip: trip),
      ),
    );
  }

  Future<void> _editTrip(BuildContext context) async {
    final updatedTrip = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTripScreen(trip: trip),
      ),
    );

    if (updatedTrip != null && onRefresh != null) {
      onRefresh!();
    }
  }

  Future<void> _deleteTrip(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Are you sure you want to delete the trip to ${trip.destination}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dbHelper = DatabaseHelper();
      try {
        await dbHelper.deleteTrip(trip.id);
        if (onRefresh != null) {
          onRefresh!();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete trip: $e')),
        );
      }
    }
  }
}