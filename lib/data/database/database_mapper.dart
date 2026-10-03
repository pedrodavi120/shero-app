import '../../domain/exception/mapper_exception.dart';
import '../../domain/hero_model.dart';
import 'entity/hero_database_entity.dart';

// Mapeador para converter entre entidades do SQLite e o modelo de domínio do app
class DatabaseMapper {
  HeroModel toHero(HeroDatabaseEntity entity) {
    try {
      return HeroModel(
        id: entity.id,
        name: entity.name,
        slug: entity.slug,
        intelligence: entity.intelligence,
        strength: entity.strength,
        speed: entity.speed,
        durability: entity.durability,
        power: entity.power,
        combat: entity.combat,
        gender: entity.gender,
        race: entity.race,
        height: entity.height,
        weight: entity.weight,
        eyeColor: entity.eyeColor,
        hairColor: entity.hairColor,
        fullName: entity.fullName,
        alterEgos: entity.alterEgos,
        aliases: entity.aliases,
        placeOfBirth: entity.placeOfBirth,
        firstAppearance: entity.firstAppearance,
        publisher: entity.publisher,
        alignment: entity.alignment,
        occupation: entity.occupation,
        base: entity.workBase,
        groupAffiliation: entity.groupAffiliation,
        relatives: entity.relatives,
        imageXs: entity.imageXs,
        imageSm: entity.imageSm,
        imageMd: entity.imageMd,
        imageLg: entity.imageLg,
      );
    } catch (e) {
      throw MapperException<HeroDatabaseEntity, HeroModel>(e.toString());
    }
  }

  List<HeroModel> toHeroes(List<HeroDatabaseEntity> entities) {
    return entities.map((entity) => toHero(entity)).toList();
  }

  HeroDatabaseEntity toHeroDatabaseEntity(HeroModel hero) {
    try {
      return HeroDatabaseEntity(
        id: hero.id,
        name: hero.name,
        slug: hero.slug,
        intelligence: hero.intelligence,
        strength: hero.strength,
        speed: hero.speed,
        durability: hero.durability,
        power: hero.power,
        combat: hero.combat,
        gender: hero.gender,
        race: hero.race,
        height: hero.height,
        weight: hero.weight,
        eyeColor: hero.eyeColor,
        hairColor: hero.hairColor,
        fullName: hero.fullName,
        alterEgos: hero.alterEgos,
        aliases: hero.aliases,
        placeOfBirth: hero.placeOfBirth,
        firstAppearance: hero.firstAppearance,
        publisher: hero.publisher,
        alignment: hero.alignment,
        occupation: hero.occupation,
        workBase: hero.base,
        groupAffiliation: hero.groupAffiliation,
        relatives: hero.relatives,
        imageXs: hero.imageXs,
        imageSm: hero.imageSm,
        imageMd: hero.imageMd,
        imageLg: hero.imageLg,
      );
    } catch (e) {
      throw MapperException<HeroModel, HeroDatabaseEntity>(e.toString());
    }
  }

  List<HeroDatabaseEntity> toHeroDatabaseEntities(List<HeroModel> heroes) {
    return heroes.map((hero) => toHeroDatabaseEntity(hero)).toList();
  }
}