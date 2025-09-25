import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../trip/trip_model.dart';
import '../trip_files_itinerary/itinerary_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  DatabaseHelper._privateConstructor();
  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._privateConstructor();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'trips_database.db');
    print('Database path: $path');
    return await openDatabase(
      path,
      version: 5, // Increment version for multiple file attachments support
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating table trips...');
    await db.execute('''
      CREATE TABLE trips(
        id TEXT PRIMARY KEY,
        country TEXT NOT NULL,
        destination TEXT NOT NULL,
        dates TEXT NOT NULL,
        imageUrl TEXT,
        daysLeft INTEGER NOT NULL,
        isActive INTEGER NOT NULL,
        start_date TEXT,
        end_date TEXT
      )
    ''');
    print('Trip table created successfully');
    
    // Create the itineraries table with file attachment support
    await db.execute('''
      CREATE TABLE itineraries(
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        day TEXT NOT NULL,
        time TEXT NOT NULL,
        activity TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        file_type INTEGER DEFAULT 0,
        file_path TEXT,
        file_name TEXT,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');
    print('Itineraries table created successfully');
    
    // Create a table for multiple file attachments
    await db.execute('''
      CREATE TABLE itinerary_attachments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itinerary_id TEXT NOT NULL,
        file_type INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        FOREIGN KEY (itinerary_id) REFERENCES itineraries (id) ON DELETE CASCADE
      )
    ''');
    print('Itinerary attachments table created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE trips ADD COLUMN start_date TEXT');
      await db.execute('ALTER TABLE trips ADD COLUMN end_date TEXT');
      print('Migration to version 2 completed: added start_date and end_date columns');
    }
    
    if (oldVersion < 3) {
      // Create the itineraries table if upgrading from version 2
      await db.execute('''
      CREATE TABLE itineraries(
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        day TEXT NOT NULL,
        time TEXT NOT NULL,
        activity TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        file_type INTEGER DEFAULT 0,
        file_path TEXT,
        file_name TEXT,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');
      print('Migration to version 3 completed: added itineraries table');
    }
    
    if (oldVersion < 4) {
      // Add file attachment columns to itineraries table
      try {
        await db.execute('ALTER TABLE itineraries ADD COLUMN file_type INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE itineraries ADD COLUMN file_path TEXT');
        await db.execute('ALTER TABLE itineraries ADD COLUMN file_name TEXT');
        print('Migration to version 4 completed: added file attachment columns');
      } catch (e) {
        print('Error during migration to version 4: $e');
        // Handle migration errors
      }
    }
    
    if (oldVersion < 5) {
      // Create a table for multiple file attachments
      await db.execute('''
        CREATE TABLE itinerary_attachments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          itinerary_id TEXT NOT NULL,
          file_type INTEGER NOT NULL,
          file_path TEXT NOT NULL,
          file_name TEXT NOT NULL,
          FOREIGN KEY (itinerary_id) REFERENCES itineraries (id) ON DELETE CASCADE
        )
      ''');
      
      // Migrate existing file attachments to the new table
      List<Map<String, dynamic>> existingItineraries = await db.query(
        'itineraries',
        where: 'file_path IS NOT NULL AND file_name IS NOT NULL AND file_type > 0',
      );
      
      for (var itinerary in existingItineraries) {
        await db.insert('itinerary_attachments', {
          'itinerary_id': itinerary['id'],
          'file_type': itinerary['file_type'],
          'file_path': itinerary['file_path'],
          'file_name': itinerary['file_name'],
        });
      }
      
      print('Migration to version 5 completed: added support for multiple attachments');
    }
  }

  Future<int> insertTrip(Trip trip) async {
    try {
      Database db = await database;
      print('Inserting trip: ${trip.toMap()}');
      int id = await db.insert('trips', trip.toMap());
      print('Insert successful, new row ID: $id');
      return id;
    } catch (e) {
      print('Insert failed: $e');
      rethrow;
    }
  }

  Future<List<Trip>> getAllTrips() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('trips');
      print('Queried ${maps.length} trips from DB');
      List<Trip> trips = List.generate(maps.length, (i) {
        final trip = Trip.fromMap(maps[i]);
        trip.updateDynamicFields();
        return trip;
      });
      print('Loaded trips: ${trips.map((t) => t.destination).toList()}');
      return trips;
    } catch (e) {
      print('Load trips failed: $e');
      return [];
    }
  }

  Future<int> updateTrip(Trip trip) async {
    try {
      Database db = await database;
      print('Updating trip: ${trip.toMap()}');
      int rowsAffected = await db.update(
        'trips',
        trip.toMap(),
        where: 'id = ?',
        whereArgs: [trip.id],
      );
      print('Update successful, rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Update failed: $e');
      rethrow;
    }
  }

  Future<int> deleteTrip(String id) async {
    try {
      Database db = await database;
      print('Deleting trip with id: $id');
      int rowsAffected = await db.delete(
        'trips',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Delete successful, rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Delete failed: $e');
      rethrow;
    }
  }
  
  // Itinerary-related methods
  Future<int> insertItinerary(Itinerary itinerary) async {
    try {
      Database db = await database;
      print('Inserting itinerary: ${itinerary.toMap()}');
      
      // Start a transaction to ensure all operations complete together
      await db.transaction((txn) async {
        // Insert the itinerary first
        await txn.insert('itineraries', itinerary.toMap());
        
        // Insert all attachments if there are any
        if (itinerary.attachments.isNotEmpty) {
          for (var attachment in itinerary.attachments) {
            await txn.insert('itinerary_attachments', {
              'itinerary_id': itinerary.id,
              'file_type': attachment.fileType.index,
              'file_path': attachment.filePath,
              'file_name': attachment.fileName,
            });
          }
        }
      });
      
      return 1; // Return success
    } catch (e) {
      print('Insert itinerary failed: $e');
      rethrow;
    }
  }

  Future<List<Itinerary>> getItinerariesForTrip(String tripId) async {
    try {
      Database db = await database;
      
      // Get all itineraries for this trip
      List<Map<String, dynamic>> itineraryMaps = await db.query(
        'itineraries',
        where: 'trip_id = ?',
        whereArgs: [tripId],
        orderBy: 'day ASC',
      );
      print('Queried ${itineraryMaps.length} itineraries for trip $tripId');
      
      // Create list of itineraries with empty attachments
      List<Itinerary> itineraries = itineraryMaps.map((map) => Itinerary.fromMap(map)).toList();
      
      // For each itinerary, load its attachments
      for (var itinerary in itineraries) {
        List<Map<String, dynamic>> attachmentMaps = await db.query(
          'itinerary_attachments',
          where: 'itinerary_id = ?',
          whereArgs: [itinerary.id],
        );
        
        // Convert the attachment maps to FileAttachment objects
        if (attachmentMaps.isNotEmpty) {
          List<FileAttachment> attachments = attachmentMaps.map((map) {
            return FileAttachment(
              fileType: FileType.values[map['file_type']],
              filePath: map['file_path'],
              fileName: map['file_name'],
            );
          }).toList();
          
          // Create a new itinerary with the attachments
          int index = itineraries.indexOf(itinerary);
          itineraries[index] = Itinerary(
            id: itinerary.id,
            tripId: itinerary.tripId,
            day: itinerary.day,
            time: itinerary.time,
            activity: itinerary.activity,
            location: itinerary.location,
            description: itinerary.description,
            icon: itinerary.icon,
            attachments: attachments,
          );
        }
      }
      
      return itineraries;
    } catch (e) {
      print('Load itineraries failed: $e');
      return [];
    }
  }

  Future<int> updateItinerary(Itinerary itinerary) async {
    try {
      Database db = await database;
      print('Updating itinerary: ${itinerary.id}');
      
      // Start a transaction
      await db.transaction((txn) async {
        // Create a modified map for the itineraries table (without the attachments field)
        final Map<String, dynamic> itineraryMap = {
          'id': itinerary.id,
          'trip_id': itinerary.tripId,
          'day': itinerary.day,
          'time': itinerary.time,
          'activity': itinerary.activity,
          'location': itinerary.location,
          'description': itinerary.description,
          'icon': itinerary.icon.codePoint.toString(),
          'file_type': itinerary.attachments.isNotEmpty ? itinerary.attachments.first.fileType.index : 0,
          'file_path': itinerary.attachments.isNotEmpty ? itinerary.attachments.first.filePath : null,
          'file_name': itinerary.attachments.isNotEmpty ? itinerary.attachments.first.fileName : null,
        };
        
        // Update the itinerary
        await txn.update(
          'itineraries',
          itineraryMap,
          where: 'id = ?',
          whereArgs: [itinerary.id],
        );
        
        // Delete all existing attachments
        await txn.delete(
          'itinerary_attachments',
          where: 'itinerary_id = ?',
          whereArgs: [itinerary.id],
        );
        
        // Insert new attachments
        for (var attachment in itinerary.attachments) {
          await txn.insert('itinerary_attachments', {
            'itinerary_id': itinerary.id,
            'file_type': attachment.fileType.index,
            'file_path': attachment.filePath,
            'file_name': attachment.fileName,
          });
        }
      });
      
      return 1; // Return success
    } catch (e) {
      print('Update itinerary failed: $e');
      rethrow;
    }
  }

  Future<int> deleteItinerary(String id) async {
    try {
      Database db = await database;
      print('Deleting itinerary with id: $id');
      
      // The ON DELETE CASCADE constraint will automatically delete related attachments
      int rowsAffected = await db.delete(
        'itineraries',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Delete successful, rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Delete itinerary failed: $e');
      rethrow;
    }
  }
  
  // Delete all itineraries for a trip (usually when deleting a trip)
  Future<int> deleteItinerariesForTrip(String tripId) async {
    try {
      Database db = await database;
      print('Deleting all itineraries for trip: $tripId');
      int rowsAffected = await db.delete(
        'itineraries',
        where: 'trip_id = ?',
        whereArgs: [tripId],
      );
      print('Delete successful, rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Delete itineraries failed: $e');
      rethrow;
    }
    
    // Get all file attachments for a specific itinerary
    Future<List<FileAttachment>> getAttachmentsForItinerary(String itineraryId) async {
      try {
        Database db = await database;
        List<Map<String, dynamic>> maps = await db.query(
          'itinerary_attachments',
          where: 'itinerary_id = ?',
          whereArgs: [itineraryId],
        );
        
        return List.generate(maps.length, (i) {
          return FileAttachment(
            fileType: FileType.values[maps[i]['file_type']],
            filePath: maps[i]['file_path'],
            fileName: maps[i]['file_name'],
          );
        });
      } catch (e) {
        print('Load attachments failed: $e');
        return [];
      }
    }
  }
}