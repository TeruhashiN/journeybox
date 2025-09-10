// Trip model
class Trip {
  final String id;
  final String country;
  final String destination;
  final String dates;
  final String imageUrl;
  final int daysLeft;
  final bool isActive;

  Trip({
    required this.id,
    required this.country,
    required this.destination,
    required this.dates,
    required this.imageUrl,
    required this.daysLeft,
    required this.isActive,
  });
}