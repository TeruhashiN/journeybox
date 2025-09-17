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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'country': country,
      'destination': destination,
      'dates': dates,
      'imageUrl': imageUrl,
      'daysLeft': daysLeft,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      country: map['country'],
      destination: map['destination'],
      dates: map['dates'],
      imageUrl: map['imageUrl'],
      daysLeft: map['daysLeft'],
      isActive: map['isActive'] == 1,
    );
  }
}