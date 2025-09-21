import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../trip/trip_model.dart';
import '../trip_files/itinerary_model.dart';

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
      version: 3,
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
    
    // Create the itineraries table
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
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');
    print('Itineraries table created successfully');
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
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');
      print('Migration to version 3 completed: added itineraries table');
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
      int id = await db.insert('itineraries', itinerary.toMap());
      print('Insert successful, new row ID: $id');
      return id;
    } catch (e) {
      print('Insert itinerary failed: $e');
      rethrow;
    }
  }

  Future<List<Itinerary>> getItinerariesForTrip(String tripId) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'itineraries',
        where: 'trip_id = ?',
        whereArgs: [tripId],
        orderBy: 'day ASC',
      );
      print('Queried ${maps.length} itineraries for trip $tripId');
      
      return List.generate(maps.length, (i) {
        return Itinerary.fromMap(maps[i]);
      });
    } catch (e) {
      print('Load itineraries failed: $e');
      return [];
    }
  }

  Future<int> updateItinerary(Itinerary itinerary) async {
    try {
      Database db = await database;
      print('Updating itinerary: ${itinerary.toMap()}');
      int rowsAffected = await db.update(
        'itineraries',
        itinerary.toMap(),
        where: 'id = ?',
        whereArgs: [itinerary.id],
      );
      print('Update successful, rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Update itinerary failed: $e');
      rethrow;
    }
  }

  Future<int> deleteItinerary(String id) async {
    try {
      Database db = await database;
      print('Deleting itinerary with id: $id');
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
  }
}