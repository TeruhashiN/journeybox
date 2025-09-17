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
      version: 1,
      onCreate: _onCreate,
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
        isActive INTEGER NOT NULL
      )
    ''');
    print('Table created successfully');
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
        return Trip.fromMap(maps[i]);
      });
      print('Loaded trips: ${trips.map((t) => t.destination).toList()}');
      return trips;
    } catch (e) {
      print('Load trips failed: $e');
      return [];
    }
  }
}