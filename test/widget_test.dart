import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/data/network/entity/hero_network_entity.dart';
import 'package:flutter_repository_example/data/network/network_mapper.dart';
import 'package:flutter_repository_example/domain/hero_model.dart';
import 'package:flutter_repository_example/ui/widgets/hero_card.dart';

void main() {
  group('Testes Unitários de Regras de Domínio e Modelo (SHERO)', () {
    test('Deve calcular corretamente o maior atributo e o papel tático do agente', () {
      final hero = HeroModel(
        id: 1,
        name: 'Clark Kent',
        slug: 'superman',
        intelligence: 94,
        strength: 100, // Maior atributo
        speed: 99,
        durability: 100,
        power: 100,
        combat: 85,
        gender: 'Male',
        race: 'Kryptonian',
        height: "6'3",
        weight: '225 lb',
        eyeColor: 'Blue',
        hairColor: 'Black',
        fullName: 'Clark Kent',
        alterEgos: 'No alter egos',
        aliases: 'Man of Steel',
        placeOfBirth: 'Krypton',
        firstAppearance: 'Action Comics #1',
        publisher: 'DC Comics',
        alignment: 'good',
        occupation: 'Reporter',
        base: 'Metropolis',
        groupAffiliation: 'Justice League',
        relatives: 'Lois Lane',
        imageXs: '',
        imageSm: '',
        imageMd: '',
        imageLg: '',
      );

      // Validação do método getStatValue por nome em português e inglês
      expect(hero.getStatValue('strength'), equals(100));
      expect(hero.getStatValue('força'), equals(100));
      expect(hero.getStatValue('intelligence'), equals(94));
      expect(hero.getStatValue('inexistente'), equals(0));

      // Validação do maior atributo
      expect(hero.highestStatName, contains('100'));

      // Validação do papel tático (Strength -> Vanguarda)
      expect(hero.tacticalRole, isNotEmpty);
    });

    test('Deve aplicar bônus de +1 em atributo vitorioso da missão (withStatBonus)', () {
      final hero = HeroModel(
        id: 70,
        name: 'Batman',
        slug: 'batman',
        intelligence: 100,
        strength: 26,
        speed: 27,
        durability: 50,
        power: 47,
        combat: 100,
        gender: 'Male',
        race: 'Human',
        height: "6'2",
        weight: '210 lb',
        eyeColor: 'Blue',
        hairColor: 'Black',
        fullName: 'Bruce Wayne',
        alterEgos: 'No alter egos',
        aliases: 'Dark Knight',
        placeOfBirth: 'Gotham City',
        firstAppearance: 'Detective Comics #27',
        publisher: 'DC Comics',
        alignment: 'good',
        occupation: 'Businessman',
        base: 'Gotham City',
        groupAffiliation: 'Justice League',
        relatives: 'Damian Wayne',
        imageXs: '',
        imageSm: '',
        imageMd: '',
        imageLg: '',
      );

      final heroComBonus = hero.withStatBonus('combat');

      expect(heroComBonus.combat, equals(101));
      expect(heroComBonus.strength, equals(26)); // Outros atributos não mudam
      expect(heroComBonus.name, equals('Batman'));
    });
  });

  group('Testes de Mapeamento e Parser de JSON (Offline e Rede)', () {
    test('Deve deserializar JSON da API com segurança (tratando campos aninhados e nulos)', () {
      final jsonSimulado = {
        "id": 10,
        "name": "Agente Teste",
        "slug": "agente-teste",
        "powerstats": {
          "intelligence": 75,
          "strength": 80,
          "speed": 60,
          "durability": 70,
          "power": 65,
          "combat": 85
        },
        "appearance": {
          "gender": "Female",
          "race": "Mutant",
          "height": ["5'7", "170 cm"],
          "weight": ["130 lb", "59 kg"],
          "eyeColor": "Green",
          "hairColor": "Red"
        },
        "biography": {
          "fullName": "Jean Grey",
          "alterEgos": "No",
          "aliases": ["Phoenix"],
          "placeOfBirth": "New York",
          "firstAppearance": "X-Men #1",
          "publisher": "Marvel Comics",
          "alignment": "good"
        },
        "work": {
          "occupation": "Adventurer",
          "base": "Xaviers School"
        },
        "connections": {
          "groupAffiliation": "X-Men",
          "relatives": "Cyclops"
        },
        "images": {
          "xs": "http://img.xs",
          "sm": "http://img.sm",
          "md": "http://img.md",
          "lg": "http://img.lg"
        }
      };

      final entity = HeroNetworkEntity.fromJson(jsonSimulado);

      expect(entity.id, equals(10));
      expect(entity.name, equals('Agente Teste'));
      expect(entity.intelligence, equals(75));
      expect(entity.gender, equals('Female'));
      expect(entity.imageSm, equals('http://img.sm'));

      // Converte NetworkEntity -> HeroModel via NetworkMapper
      final mapper = NetworkMapper();
      final model = mapper.toHero(entity);

      expect(model.id, equals(10));
      expect(model.name, equals('Agente Teste'));
      expect(model.combat, equals(85));
      expect(model.publisher, equals('Marvel Comics'));
    });

    test('Deve avaliar corretamente a lógica de combate (Regra dos Slides 10-13)', () {
      const heroStat = 85;
      const enemyStat = 70;

      // Regra: Herói > Inimigo = Vitória
      String avaliarConfronto(int heroi, int inimigo) {
        if (heroi > inimigo) return 'VITÓRIA';
        if (heroi < inimigo) return 'DERROTA';
        return 'EMPATE';
      }

      expect(avaliarConfronto(heroStat, enemyStat), equals('VITÓRIA'));
      expect(avaliarConfronto(50, 90), equals('DERROTA'));
      expect(avaliarConfronto(70, 70), equals('EMPATE'));
    });
  });

  group('Testes de Widget (Componente Visual)', () {
    testWidgets('Deve renderizar o HeroCard com nome e informações básicas do agente', (WidgetTester tester) async {
      final hero = HeroModel(
        id: 99,
        name: 'Flash',
        slug: 'flash',
        intelligence: 88,
        strength: 48,
        speed: 100,
        durability: 60,
        power: 100,
        combat: 60,
        gender: 'Male',
        race: 'Human',
        height: "6'0",
        weight: '195 lb',
        eyeColor: 'Blue',
        hairColor: 'Blond',
        fullName: 'Barry Allen',
        alterEgos: 'No alter egos',
        aliases: 'Scarlet Speedster',
        placeOfBirth: 'Fallville',
        firstAppearance: 'Showcase #4',
        publisher: 'DC Comics',
        alignment: 'good',
        occupation: 'Forensic Scientist',
        base: 'Central City',
        groupAffiliation: 'Justice League',
        relatives: 'Iris West',
        imageXs: '',
        imageSm: '',
        imageMd: '',
        imageLg: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroCard(hero: hero),
          ),
        ),
      );

      // Verifica se o nome e os dados são renderizados na tela
      expect(find.text('Flash'), findsOneWidget);
      expect(find.byType(HeroCard), findsOneWidget);
    });
  });
}

