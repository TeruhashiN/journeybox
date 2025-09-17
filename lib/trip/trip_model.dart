// Trip model
class Trip {
  final String id;
  final String country;
  final String destination;
  final String dates;
  final String imageUrl;
  int daysLeft;
  bool isActive;
  String? startDate;
  String? endDate;

  Trip({
    required this.id,
    required this.country,
    required this.destination,
    required this.dates,
    required this.imageUrl,
    required this.daysLeft,
    required this.isActive,
    this.startDate,
    this.endDate,
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
      'start_date': startDate,
      'end_date': endDate,
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
      startDate: map['start_date'],
      endDate: map['end_date'],
    );
  }

  void updateDynamicFields() {
    if (startDate == null || endDate == null) return;

    DateTime now = DateTime.now();
    DateTime sDate = DateTime.parse(startDate!);
    DateTime eDate = DateTime.parse(endDate!);

    if (now.isBefore(sDate)) {
      // Upcoming
      daysLeft = sDate.difference(now).inDays;
      isActive = false;
    } else if (now.isAfter(eDate)) {
      // Finished
      daysLeft = -1;
      isActive = false;
    } else {
      // Active
      daysLeft = eDate.difference(now).inDays;
      isActive = true;
    }
  }
}