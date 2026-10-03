import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Classe base para inicializar o SQLite com as tabelas de cache e esquadrão
abstract class BaseDao {
  static const int databaseVersion = 1;
  static const String databaseName = 'shero_database.db';

  static Database? _database;

  @protected
  Future<Database> getDb() async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: (db, version) async {
        final batch = db.batch();
        _createHeroesCacheTable(batch);
        _createSquadTable(batch);
        await batch.commit();
      },
    );
  }

  // Tabela que armazena os heróis vindos da API para funcionar Offline
  void _createHeroesCacheTable(Batch batch) {
    batch.execute('''
      CREATE TABLE heroes_cache (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        slug TEXT,
        intelligence INTEGER,
        strength INTEGER,
        speed INTEGER,
        durability INTEGER,
        power INTEGER,
        combat INTEGER,
        gender TEXT,
        race TEXT,
        height TEXT,
        weight TEXT,
        eye_color TEXT,
        hair_color TEXT,
        full_name TEXT,
        alter_egos TEXT,
        aliases TEXT,
        place_of_birth TEXT,
        first_appearance TEXT,
        publisher TEXT,
        alignment TEXT,
        occupation TEXT,
        work_base TEXT,
        group_affiliation TEXT,
        relatives TEXT,
        image_xs TEXT,
        image_sm TEXT,
        image_md TEXT,
        image_lg TEXT
      );
    ''');
  }

  // Tabela que armazena os membros recrutados do esquadrão do jogador (máximo 15)
  void _createSquadTable(Batch batch) {
    batch.execute('''
      CREATE TABLE squad (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        slug TEXT,
        intelligence INTEGER,
        strength INTEGER,
        speed INTEGER,
        durability INTEGER,
        power INTEGER,
        combat INTEGER,
        gender TEXT,
        race TEXT,
        height TEXT,
        weight TEXT,
        eye_color TEXT,
        hair_color TEXT,
        full_name TEXT,
        alter_egos TEXT,
        aliases TEXT,
        place_of_birth TEXT,
        first_appearance TEXT,
        publisher TEXT,
        alignment TEXT,
        occupation TEXT,
        work_base TEXT,
        group_affiliation TEXT,
        relatives TEXT,
        image_xs TEXT,
        image_sm TEXT,
        image_md TEXT,
        image_lg TEXT,
        recruited_at TEXT
      );
    ''');
  }
}