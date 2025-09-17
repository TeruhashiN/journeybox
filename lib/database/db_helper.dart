import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../trip/trip_model.dart';

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
      version: 2,
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
    print('Table created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE trips ADD COLUMN start_date TEXT');
      await db.execute('ALTER TABLE trips ADD COLUMN end_date TEXT');
      print('Migration to version 2 completed: added start_date and end_date columns');
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
}