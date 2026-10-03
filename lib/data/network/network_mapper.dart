import '../../domain/exception/mapper_exception.dart';
import '../../domain/hero_model.dart';
import 'entity/hero_network_entity.dart';

// Mapeador que converte dados da rede para o modelo de domínio do aplicativo.
class NetworkMapper {
  HeroModel toHero(HeroNetworkEntity entity) {
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
        base: entity.base,
        groupAffiliation: entity.groupAffiliation,
        relatives: entity.relatives,
        imageXs: entity.imageXs,
        imageSm: entity.imageSm,
        imageMd: entity.imageMd,
        imageLg: entity.imageLg,
      );
    } catch (e) {
      throw MapperException<HeroNetworkEntity, HeroModel>(e.toString());
    }
  }

  List<HeroModel> toHeroes(List<HeroNetworkEntity> entities) {
    return entities.map((entity) => toHero(entity)).toList();
  }
}