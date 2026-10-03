// Entidade da camada de rede (DTO) que espelha os dados que chegam da API REST (json-server).
// Como estudante, fiz o parser manual no fromJson para garantir que nenhum campo nulo quebre o app!
class HeroNetworkEntity {
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
  final String base;

  final String groupAffiliation;
  final String relatives;

  final String imageXs;
  final String imageSm;
  final String imageMd;
  final String imageLg;

  HeroNetworkEntity({
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

  factory HeroNetworkEntity.fromJson(Map<String, dynamic> json) {
    // Trata o id que às vezes vem como String do json-server
    final parsedId = int.tryParse(json['id'].toString()) ?? 0;

    final powerstats = (json['powerstats'] as Map<String, dynamic>?) ?? {};
    final appearance = (json['appearance'] as Map<String, dynamic>?) ?? {};
    final biography = (json['biography'] as Map<String, dynamic>?) ?? {};
    final work = (json['work'] as Map<String, dynamic>?) ?? {};
    final connections = (json['connections'] as Map<String, dynamic>?) ?? {};
    final images = (json['images'] as Map<String, dynamic>?) ?? {};

    // Helper para converter lista de Strings (como height, weight, aliases) em texto legível
    String listToText(dynamic list) {
      if (list is List) {
        return list.where((e) => e != null && e.toString().isNotEmpty && e.toString() != '-').join(', ');
      }
      return list?.toString() ?? '-';
    }

    return HeroNetworkEntity(
      id: parsedId,
      name: json['name']?.toString() ?? 'Herói Sem Nome',
      slug: json['slug']?.toString() ?? '',
      intelligence: int.tryParse(powerstats['intelligence']?.toString() ?? '0') ?? 0,
      strength: int.tryParse(powerstats['strength']?.toString() ?? '0') ?? 0,
      speed: int.tryParse(powerstats['speed']?.toString() ?? '0') ?? 0,
      durability: int.tryParse(powerstats['durability']?.toString() ?? '0') ?? 0,
      power: int.tryParse(powerstats['power']?.toString() ?? '0') ?? 0,
      combat: int.tryParse(powerstats['combat']?.toString() ?? '0') ?? 0,
      gender: appearance['gender']?.toString() ?? '-',
      race: appearance['race']?.toString() ?? '-',
      height: listToText(appearance['height']),
      weight: listToText(appearance['weight']),
      eyeColor: appearance['eyeColor']?.toString() ?? '-',
      hairColor: appearance['hairColor']?.toString() ?? '-',
      fullName: biography['fullName']?.toString() ?? '-',
      alterEgos: biography['alterEgos']?.toString() ?? '-',
      aliases: listToText(biography['aliases']),
      placeOfBirth: biography['placeOfBirth']?.toString() ?? '-',
      firstAppearance: biography['firstAppearance']?.toString() ?? '-',
      publisher: biography['publisher']?.toString() ?? 'Desconhecido',
      alignment: biography['alignment']?.toString() ?? 'neutro',
      occupation: work['occupation']?.toString() ?? '-',
      base: work['base']?.toString() ?? '-',
      groupAffiliation: connections['groupAffiliation']?.toString() ?? '-',
      relatives: connections['relatives']?.toString() ?? '-',
      imageXs: images['xs']?.toString() ?? '',
      imageSm: images['sm']?.toString() ?? '',
      imageMd: images['md']?.toString() ?? '',
      imageLg: images['lg']?.toString() ?? '',
    );
  }
}
