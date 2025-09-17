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
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
  }

  Future<int> insertTrip(Trip trip) async {
    Database db = await database;
    return await db.insert('trips', trip.toMap());
  }

  Future<List<Trip>> getAllTrips() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('trips');
    return List.generate(maps.length, (i) {
      return Trip.fromMap(maps[i]);
    });
  }
}