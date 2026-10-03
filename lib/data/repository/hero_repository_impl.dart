import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/hero_model.dart';
import '../database/dao/hero_dao.dart';
import '../database/dao/squad_dao.dart';
import '../database/database_mapper.dart';
import '../network/client/api_client.dart';
import '../network/network_mapper.dart';
import 'hero_repository.dart';

// Implementação do repositório contendo toda a lógica de negócio e estratégia Offline-First
class HeroRepositoryImpl implements HeroRepository {
  final ApiClient apiClient;
  final NetworkMapper networkMapper;
  final DatabaseMapper databaseMapper;
  final HeroDao heroDao;
  final SquadDao squadDao;
  final SharedPreferences sharedPreferences;

  HeroRepositoryImpl({
    required this.apiClient,
    required this.networkMapper,
    required this.databaseMapper,
    required this.heroDao,
    required this.squadDao,
    required this.sharedPreferences,
  });

  // Chaves do SharedPreferences para o Contrato Diário
  static const String keyLastDrawDate = 'last_contract_draw_date';
  static const String keyLastDrawnHeroId = 'last_contract_hero_id';

  @override
  Future<List<HeroModel>> getHeroes({required int page, required int limit}) async {
    // Tentamos buscar da API remota primeiro (como pede o PDF)
    try {
      final networkEntities = await apiClient.getHeroes(page: page, limit: limit);
      final heroes = networkMapper.toHeroes(networkEntities);

      // Salvamos em cache no SQLite para quando ficar sem internet
      if (heroes.isNotEmpty) {
        final dbEntities = databaseMapper.toHeroDatabaseEntities(heroes);
        await heroDao.insertAll(dbEntities);
      }

      return heroes;
    } catch (e) {
      debugPrint("Sem conexão com a API, carregando do cache SQLite local: $e");

      // Se falhar a conexão (modo offline), buscamos do banco de dados local
      final offset = (page - 1) * limit;
      final cachedEntities = await heroDao.selectAll(limit: limit, offset: offset);
      return databaseMapper.toHeroes(cachedEntities);
    }
  }

  @override
  Future<HeroModel> getHeroById(int id) async {
    // 1. Tenta buscar da API preferencialmente
    try {
      final networkEntity = await apiClient.getHeroById(id);
      final hero = networkMapper.toHero(networkEntity);
      
      // Atualiza o cache local desse herói
      await heroDao.insert(databaseMapper.toHeroDatabaseEntity(hero));
      return hero;
    } catch (e) {
      debugPrint("Buscando herói $id do banco SQLite offline");
      // 2. Se falhar ou estiver offline, busca no SQLite
      final cached = await heroDao.selectById(id);
      if (cached != null) {
        return databaseMapper.toHero(cached);
      }
      rethrow;
    }
  }

  @override
  Future<List<HeroModel>> getSquad() async {
    // Retorna todos os heróis recrutados do banco SQLite
    final entities = await squadDao.getSquad();
    return databaseMapper.toHeroes(entities);
  }

  @override
  Future<bool> addToSquad(HeroModel hero) async {
    // Adiciona o herói à tabela squad (máximo 15 heróis)
    final dbEntity = databaseMapper.toHeroDatabaseEntity(hero);
    return await squadDao.insertToSquad(dbEntity);
  }

  @override
  Future<void> removeFromSquad(int id) async {
    // Remove o herói liberando uma vaga no esquadrão
    await squadDao.removeFromSquad(id);
  }

  @override
  Future<bool> isInSquad(int id) async {
    // Checa se o herói já foi recrutado
    return await squadDao.isInSquad(id);
  }

  @override
  Future<int> getSquadCount() async {
    return await squadDao.countSquad();
  }

  @override
  Future<HeroModel> getDailyHero({bool forceNew = false}) async {
    final now = DateTime.now();
    final todayString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final lastDate = sharedPreferences.getString(keyLastDrawDate);
    final lastHeroId = sharedPreferences.getInt(keyLastDrawnHeroId);

    // Se já sorteou hoje e não estamos forçando novo sorteio para teste
    if (!forceNew && lastDate == todayString && lastHeroId != null) {
      try {
        return await getHeroById(lastHeroId);
      } catch (_) {
        // Se der algum erro buscando pelo id salvo, continua para sortear
      }
    }

    // Caso contrário, fazemos um novo sorteio de um herói do dia
    // Pegamos um herói do cache local ou buscamos um da API
    HeroModel? drawnHero;
    final cachedHero = await heroDao.getRandomHero();

    if (cachedHero != null) {
      drawnHero = databaseMapper.toHero(cachedHero);
    } else {
      // Se o cache ainda estiver vazio, busca a lista da API e pega um aleatório
      final list = await getHeroes(page: 1, limit: 20);
      if (list.isNotEmpty) {
        drawnHero = list[Random().nextInt(list.length)];
      }
    }

    if (drawnHero == null) {
      // Fallback de segurança se tudo falhar
      throw Exception("Não foi possível sortear um herói diário.");
    }

    // Salva a data de hoje e o id do herói no SharedPreferences
    await sharedPreferences.setString(keyLastDrawDate, todayString);
    await sharedPreferences.setInt(keyLastDrawnHeroId, drawnHero.id);

    return drawnHero;
  }

  @override
  Future<HeroModel?> getRandomEnemy(List<int> excludedIds) async {
    // Sorteia um inimigo do catálogo que NÃO esteja na lista de excluídos (esquadrão)
    final dbHero = await heroDao.getRandomHero(excludeIds: excludedIds);
    if (dbHero != null) {
      return databaseMapper.toHero(dbHero);
    }

    // Se o banco ainda não tiver heróis suficientes no cache, busca uma página da API
    try {
      final heroes = await getHeroes(page: 1, limit: 30);
      final available = heroes.where((h) => !excludedIds.contains(h.id)).toList();
      if (available.isNotEmpty) {
        return available[Random().nextInt(available.length)];
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<void> updateSquadHeroStat(int heroId, String statName) async {
    // Busca o herói no esquadrão, incrementa +1 no atributo e salva no SQLite
    final squad = await getSquad();
    final index = squad.indexWhere((h) => h.id == heroId);
    if (index != -1) {
      final hero = squad[index];
      final updatedHero = hero.withStatBonus(statName);
      final dbEntity = databaseMapper.toHeroDatabaseEntity(updatedHero);
      await squadDao.updateSquadHero(dbEntity);
    }
  }
}
