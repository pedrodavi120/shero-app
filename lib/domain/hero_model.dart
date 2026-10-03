// Modelo de domínio que representa o Herói/Agente no nosso aplicativo.
// Criamos essa classe para centralizar todas as informações do herói vindas da API e do Banco Local.
class HeroModel {
  final int id;
  final String name;
  final String slug;

  // Powerstats (atributos de combate)
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  // Appearance (aparência física)
  final String gender;
  final String race;
  final String height;
  final String weight;
  final String eyeColor;
  final String hairColor;

  // Biography (origem e publicação)
  final String fullName;
  final String alterEgos;
  final String aliases;
  final String placeOfBirth;
  final String firstAppearance;
  final String publisher;
  final String alignment;

  // Work (trabalho)
  final String occupation;
  final String base;

  // Connections (afiliações e parentes)
  final String groupAffiliation;
  final String relatives;

  // Images (URLs das imagens em diferentes tamanhos)
  final String imageXs;
  final String imageSm;
  final String imageMd;
  final String imageLg;

  HeroModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
    required this.fullName,
    required this.alterEgos,
    required this.aliases,
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.publisher,
    required this.alignment,
    required this.occupation,
    required this.base,
    required this.groupAffiliation,
    required this.relatives,
    required this.imageXs,
    required this.imageSm,
    required this.imageMd,
    required this.imageLg,
  });

  // Retorna o valor de um atributo específico pelo nome (útil para as disputas da missão)
  int getStatValue(String statName) {
    switch (statName.toLowerCase()) {
      case 'intelligence':
      case 'inteligência':
        return intelligence;
      case 'strength':
      case 'força':
        return strength;
      case 'speed':
      case 'velocidade':
        return speed;
      case 'durability':
      case 'durabilidade':
        return durability;
      case 'power':
      case 'poder':
        return power;
      case 'combat':
      case 'combate':
        return combat;
      default:
        return 0;
    }
  }

  // Descobre qual é o maior atributo do herói para exibir no card do esquadrão
  String get highestStatName {
    final stats = {
      'Inteligência': intelligence,
      'Força': strength,
      'Velocidade': speed,
      'Durabilidade': durability,
      'Poder': power,
      'Combate': combat,
    };

    var highestName = 'Força';
    var highestValue = -1;

    stats.forEach((key, value) {
      if (value > highestValue) {
        highestValue = value;
        highestName = key;
      }
    });

    return "$highestName ($highestValue)";
  }

  // Papel tático baseado no maior atributo
  String get tacticalRole {
    final stats = {
      'Estrategista': intelligence,
      'Vanguarda': strength,
      'Velocista / Batedor': speed,
      'Defensor': durability,
      'Artilheiro de Choque': power,
      'Mestre de Combate': combat,
    };

    var role = 'Agente Tático';
    var maxVal = -1;

    stats.forEach((key, val) {
      if (val > maxVal) {
        maxVal = val;
        role = key;
      }
    });

    return role;
  }

  // Retorna uma cópia do herói com +1 no atributo sorteado após vencer a missão
  HeroModel withStatBonus(String statName) {
    return HeroModel(
      id: id,
      name: name,
      slug: slug,
      intelligence: statName.toLowerCase() == 'intelligence' ? intelligence + 1 : intelligence,
      strength: statName.toLowerCase() == 'strength' ? strength + 1 : strength,
      speed: statName.toLowerCase() == 'speed' ? speed + 1 : speed,
      durability: statName.toLowerCase() == 'durability' ? durability + 1 : durability,
      power: statName.toLowerCase() == 'power' ? power + 1 : power,
      combat: statName.toLowerCase() == 'combat' ? combat + 1 : combat,
      gender: gender,
      race: race,
      height: height,
      weight: weight,
      eyeColor: eyeColor,
      hairColor: hairColor,
      fullName: fullName,
      alterEgos: alterEgos,
      aliases: aliases,
      placeOfBirth: placeOfBirth,
      firstAppearance: firstAppearance,
      publisher: publisher,
      alignment: alignment,
      occupation: occupation,
      base: base,
      groupAffiliation: groupAffiliation,
      relatives: relatives,
      imageXs: imageXs,
      imageSm: imageSm,
      imageMd: imageMd,
      imageLg: imageLg,
    );
  }
}
