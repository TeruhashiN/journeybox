import 'package:flutter/material.dart';

enum FileType { none, image, pdf, docx }

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
