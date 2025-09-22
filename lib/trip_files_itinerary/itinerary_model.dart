import 'package:flutter/material.dart';

class Itinerary {
  final String id;
  final String tripId;
  final String day;
  final String time;
  final String activity;
  final String location;
  final String description;
  final IconData icon;

  Itinerary({
    required this.id,
    required this.tripId,
    required this.day,
    required this.time,
    required this.activity,
    required this.location,
    required this.description,
    required this.icon,
  });

  // Convert IconData to string for database storage
  String _iconToString() {
    return icon.codePoint.toString();
  }

  // Convert string back to IconData
  static IconData _stringToIcon(String iconCode) {
    return IconData(int.parse(iconCode), fontFamily: 'MaterialIcons');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'day': day,
      'time': time,
      'activity': activity,
      'location': location,
      'description': description,
      'icon': _iconToString(),
    };
  }

  factory Itinerary.fromMap(Map<String, dynamic> map) {
    return Itinerary(
      id: map['id'],
      tripId: map['trip_id'],
      day: map['day'],
      time: map['time'],
      activity: map['activity'],
      location: map['location'],
      description: map['description'],
      icon: _stringToIcon(map['icon']),
    );
  }

  // Create a copy of this Itinerary with the given fields replaced with new values
  Itinerary copyWith({
    String? id,
    String? tripId,
    String? day,
    String? time,
    String? activity,
    String? location,
    String? description,
    IconData? icon,
  }) {
    return Itinerary(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      day: day ?? this.day,
      time: time ?? this.time,
      activity: activity ?? this.activity,
      location: location ?? this.location,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }
}