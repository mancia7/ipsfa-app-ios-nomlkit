//import 'package:inventario/classes/general.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  factory DatabaseHelper() => instance;
  //GeneralMethods general = GeneralMethods();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('interna.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final firstRun = prefs.getBool('first_run') ?? true;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    if(firstRun){
      await prefs.setBool('first_run', false);
      final file = File(join(dbPath, 'interna.db'));
    if (await file.exists()) {
      await file.delete();
    }
    }
    
    

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  //Metodos para manejar los datos de base de datos interna
  Future<int> insertHuella(Map<String, dynamic> request) async {
    final db = await database;
    return await db.insert('huella', request);
  }

  Future<int> deleteHuella(String dui) async {
    final db = await database;
    return await db.update('huella', {'aceptoHuella': 0},
    where: 'dui = ? and aceptoHuella = 1',
     whereArgs: [dui]);
  }

   //Actualizar huella
  Future<int> updateHuella(Map<String, dynamic> request) async {
    final db = await database;
    return await db.update(
      'huella',
      request,
      where: 'dui = ?',
      whereArgs: [request['dui']],
    );
  }


  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE huella (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        aceptoHuella TINYINT(1) DEFAULT 0,
        dui TEXT NOT NULL UNIQUE,
        mostroMsj TINYINT(1) DEFAULT 0

      )
    ''');
  }
}