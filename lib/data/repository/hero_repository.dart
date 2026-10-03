import '../../domain/hero_model.dart';

// Interface do repositório para abstrair o acesso a dados da UI
abstract class HeroRepository {
  Future<List<HeroModel>> getHeroes({required int page, required int limit});
  Future<HeroModel> getHeroById(int id);
  Future<List<HeroModel>> getSquad();
  Future<bool> addToSquad(HeroModel hero);
  Future<void> removeFromSquad(int id);
  Future<bool> isInSquad(int id);
  Future<int> getSquadCount();
  Future<HeroModel> getDailyHero({bool forceNew = false});
  Future<HeroModel?> getRandomEnemy(List<int> excludedIds);
  Future<void> updateSquadHeroStat(int heroId, String statName);
}
