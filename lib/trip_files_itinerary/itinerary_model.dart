import 'package:flutter/material.dart';

enum FileType {
  none,
  image,
  pdf,
  docx
}

// Class to represent a single file attachment
class FileAttachment {
  final FileType fileType;
  final String filePath;
  final String fileName;
  
  FileAttachment({
    required this.fileType,
    required this.filePath,
    required this.fileName,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'file_type': fileType.index,
      'file_path': filePath,
      'file_name': fileName,
    };
  }
  
  factory FileAttachment.fromMap(Map<String, dynamic> map) {
    return FileAttachment(
      fileType: FileType.values[map['file_type']],
      filePath: map['file_path'],
      fileName: map['file_name'],
    );
  }
}

class Itinerary {
  final String id;
  final String tripId;
  final String day;
  final String time;
  final String activity;
  final String location;
  final String description;
  final IconData icon;
  final List<FileAttachment> attachments;
  
  // Legacy fields for backward compatibility
  FileType get fileType => attachments.isNotEmpty ? attachments.first.fileType : FileType.none;
  String? get filePath => attachments.isNotEmpty ? attachments.first.filePath : null;
  String? get fileName => attachments.isNotEmpty ? attachments.first.fileName : null;

  Itinerary({
    required this.id,
    required this.tripId,
    required this.day,
    required this.time,
    required this.activity,
    required this.location,
    required this.description,
    required this.icon,
    List<FileAttachment>? attachments,
    // Legacy parameters for backward compatibility
    FileType fileType = FileType.none,
    String? filePath,
    String? fileName,
  }) : this.attachments = _initializeAttachments(
         attachments,
         fileType,
         filePath,
         fileName
       );
  
  // Helper method to initialize attachments properly
  static List<FileAttachment> _initializeAttachments(
    List<FileAttachment>? attachments,
    FileType fileType,
    String? filePath,
    String? fileName
  ) {
    // If attachments are provided, use them
    if (attachments != null && attachments.isNotEmpty) {
      return attachments;
    }
    
    // Otherwise, if we have legacy file info, create a single attachment
    if (filePath != null && fileName != null && fileType != FileType.none) {
      return [FileAttachment(fileType: fileType, filePath: filePath, fileName: fileName)];
    }
    
    // Default to empty list
    return [];
  }

  // Convert IconData to string for database storage
  String _iconToString() {
    return icon.codePoint.toString();
  }

  // Convert string back to IconData
  static IconData _stringToIcon(String iconCode) {
    return IconData(int.parse(iconCode), fontFamily: 'MaterialIcons');
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'id': id,
      'trip_id': tripId,
      'day': day,
      'time': time,
      'activity': activity,
      'location': location,
      'description': description,
      'icon': _iconToString(),
      'attachments': attachments.map((attachment) => attachment.toMap()).toList(),
      
      // Include legacy fields for backward compatibility
      'file_type': attachments.isNotEmpty ? attachments.first.fileType.index : 0,
      'file_path': attachments.isNotEmpty ? attachments.first.filePath : null,
      'file_name': attachments.isNotEmpty ? attachments.first.fileName : null,
    };
    return map;
  }

  factory Itinerary.fromMap(Map<String, dynamic> map) {
    // Handle both new and legacy formats
    List<FileAttachment> attachmentsList = [];
    
    if (map.containsKey('attachments') && map['attachments'] is List) {
      attachmentsList = (map['attachments'] as List)
          .map((attachment) => FileAttachment.fromMap(attachment))
          .toList();
    } else if (map['file_path'] != null && map['file_name'] != null) {
      // Legacy format - create a single attachment
      attachmentsList = [
        FileAttachment(
          fileType: FileType.values[map['file_type'] ?? 0],
          filePath: map['file_path'],
          fileName: map['file_name'],
        )
      ];
    }
    
    return Itinerary(
      id: map['id'],
      tripId: map['trip_id'],
      day: map['day'],
      time: map['time'],
      activity: map['activity'],
      location: map['location'],
      description: map['description'],
      icon: _stringToIcon(map['icon']),
      attachments: attachmentsList,
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
    List<FileAttachment>? attachments,
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
      attachments: attachments ?? this.attachments,
    );
  }
  
  // Helper method to check if this itinerary has any attachments
  bool get hasAttachments => attachments.isNotEmpty;
  
  // Legacy method for backward compatibility
  bool get hasAttachment => hasAttachments;
  
  // Helper method to get attachments by file type
  List<FileAttachment> getAttachmentsByType(FileType type) {
    return attachments.where((attachment) => attachment.fileType == type).toList();
  }
  
  // Helper method to get the file extension for a specific file type
  static String? getFileExtension(FileType fileType) {
    switch (fileType) {
      case FileType.image:
        return 'jpg'; // Could be different based on actual image type
      case FileType.pdf:
        return 'pdf';
      case FileType.docx:
        return 'docx';
      default:
        return null;
    }
  }
  
  // Legacy method for backward compatibility
  String? get fileExtension => hasAttachments ?
      getFileExtension(attachments.first.fileType) : null;
}