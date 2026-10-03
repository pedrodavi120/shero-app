import 'package:sqflite/sqflite.dart';
import '../entity/hero_database_entity.dart';
import 'base_dao.dart';

// DAO para manipular a tabela de cache local dos heróis (Offline-First)
class HeroDao extends BaseDao {
  static const String tableName = 'heroes_cache';

  // Busca lista paginada de heróis salvos no cache local
  Future<List<HeroDatabaseEntity>> selectAll({int? limit, int? offset}) async {
    final Database db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      limit: limit,
      offset: offset,
      orderBy: 'id ASC',
    );

    return maps.map((m) => HeroDatabaseEntity.fromMap(m)).toList();
  }

  // Busca um herói específico pelo ID no cache local
  Future<HeroDatabaseEntity?> selectById(int id) async {
    final Database db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return HeroDatabaseEntity.fromMap(maps.first);
    }
    return null;
  }

  // Insere um lote de heróis no banco (usado ao carregar da API)
  Future<void> insertAll(List<HeroDatabaseEntity> entities) async {
    final Database db = await getDb();
    await db.transaction((txn) async {
      for (final entity in entities) {
        await txn.insert(
          tableName,
          entity.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Insere ou atualiza um único herói
  Future<void> insert(HeroDatabaseEntity entity) async {
    final Database db = await getDb();
    await db.insert(
      tableName,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retorna a quantidade total de heróis no cache
  Future<int> count() async {
    final Database db = await getDb();
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Sorteia um herói aleatório do cache, podendo excluir certos IDs (ex: heróis do meu esquadrão)
  Future<HeroDatabaseEntity?> getRandomHero({List<int>? excludeIds}) async {
    final Database db = await getDb();
    String? whereClause;
    List<dynamic>? whereArgs;

    if (excludeIds != null && excludeIds.isNotEmpty) {
      final placeholders = List.filled(excludeIds.length, '?').join(',');
      whereClause = 'id NOT IN ($placeholders)';
      whereArgs = excludeIds;
    }

    final maps = await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return HeroDatabaseEntity.fromMap(maps.first);
    }
    return null;
  }
}
