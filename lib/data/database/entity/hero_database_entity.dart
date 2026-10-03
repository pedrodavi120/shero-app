// Entidade que representa como o Herói é salvo no SQLite (tabelas de cache e esquadrão).
class HeroDatabaseEntity {
  final int id;
  final String name;
  final String slug;

  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  final String gender;
  final String race;
  final String height;
  final String weight;
  final String eyeColor;
  final String hairColor;

  final String fullName;
  final String alterEgos;
  final String aliases;
  final String placeOfBirth;
  final String firstAppearance;
  final String publisher;
  final String alignment;

  final String occupation;
  final String workBase;

  final String groupAffiliation;
  final String relatives;

  final String imageXs;
  final String imageSm;
  final String imageMd;
  final String imageLg;

  HeroDatabaseEntity({
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
    required this.workBase,
    required this.groupAffiliation,
    required this.relatives,
    required this.imageXs,
    required this.imageSm,
    required this.imageMd,
    required this.imageLg,
  });

  // Converte Map do SQLite para o Objeto
  factory HeroDatabaseEntity.fromMap(Map<String, dynamic> map) {
    return HeroDatabaseEntity(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      intelligence: map['intelligence'] as int? ?? 0,
      strength: map['strength'] as int? ?? 0,
      speed: map['speed'] as int? ?? 0,
      durability: map['durability'] as int? ?? 0,
      power: map['power'] as int? ?? 0,
      combat: map['combat'] as int? ?? 0,
      gender: map['gender'] as String? ?? '',
      race: map['race'] as String? ?? '',
      height: map['height'] as String? ?? '',
      weight: map['weight'] as String? ?? '',
      eyeColor: map['eye_color'] as String? ?? '',
      hairColor: map['hair_color'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      alterEgos: map['alter_egos'] as String? ?? '',
      aliases: map['aliases'] as String? ?? '',
      placeOfBirth: map['place_of_birth'] as String? ?? '',
      firstAppearance: map['first_appearance'] as String? ?? '',
      publisher: map['publisher'] as String? ?? '',
      alignment: map['alignment'] as String? ?? '',
      occupation: map['occupation'] as String? ?? '',
      workBase: map['work_base'] as String? ?? '',
      groupAffiliation: map['group_affiliation'] as String? ?? '',
      relatives: map['relatives'] as String? ?? '',
      imageXs: map['image_xs'] as String? ?? '',
      imageSm: map['image_sm'] as String? ?? '',
      imageMd: map['image_md'] as String? ?? '',
      imageLg: map['image_lg'] as String? ?? '',
    );
  }

  // Converte o Objeto para Map inserível no SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'intelligence': intelligence,
      'strength': strength,
      'speed': speed,
      'durability': durability,
      'power': power,
      'combat': combat,
      'gender': gender,
      'race': race,
      'height': height,
      'weight': weight,
      'eye_color': eyeColor,
      'hair_color': hairColor,
      'full_name': fullName,
      'alter_egos': alterEgos,
      'aliases': aliases,
      'place_of_birth': placeOfBirth,
      'first_appearance': firstAppearance,
      'publisher': publisher,
      'alignment': alignment,
      'occupation': occupation,
      'work_base': workBase,
      'group_affiliation': groupAffiliation,
      'relatives': relatives,
      'image_xs': imageXs,
      'image_sm': imageSm,
      'image_md': imageMd,
      'image_lg': imageLg,
    };
  }
}
