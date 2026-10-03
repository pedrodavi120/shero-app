import 'package:sqflite/sqflite.dart';
import '../entity/hero_database_entity.dart';
import 'base_dao.dart';

// DAO para manipular os agentes recrutados para o Esquadrão (tabela squad)
class SquadDao extends BaseDao {
  static const String tableName = 'squad';
  static const int maxSquadMembers = 15;

  // Lista todos os agentes do esquadrão
  Future<List<HeroDatabaseEntity>> getSquad() async {
    final Database db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'recruited_at DESC, id ASC',
    );
    return maps.map((m) => HeroDatabaseEntity.fromMap(m)).toList();
  }

  // Verifica quantos agentes já foram recrutados (máximo 15)
  Future<int> countSquad() async {
    final Database db = await getDb();
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Verifica se um herói já faz parte do esquadrão
  Future<bool> isInSquad(int id) async {
    final Database db = await getDb();
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Adiciona um novo herói ao esquadrão
  Future<bool> insertToSquad(HeroDatabaseEntity entity) async {
    final Database db = await getDb();
    final currentCount = await countSquad();

    if (currentCount >= maxSquadMembers) {
      return false; // Atingiu a capacidade máxima de 15 agentes
    }

    final map = entity.toMap();
    map['recruited_at'] = DateTime.now().toIso8601String();

    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  // Remove um agente do esquadrão (Dispensar)
  Future<int> removeFromSquad(int id) async {
    final Database db = await getDb();
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Atualiza um herói no esquadrão (por exemplo, quando ganha +1 em um atributo na missão)
  Future<void> updateSquadHero(HeroDatabaseEntity entity) async {
    final Database db = await getDb();
    await db.update(
      tableName,
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }
}
