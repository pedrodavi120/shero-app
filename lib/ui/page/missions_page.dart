import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository_impl.dart';
import '../../domain/hero_model.dart';

// Modelo auxiliar para representar um Round da Missão
class MissionRound {
  final int roundNumber;
  final String attributeName; // Atributo em disputa (ex: "Força")
  final String statKey; // Chave em inglês para busca no HeroModel (ex: "strength")
  final HeroModel enemy; // Inimigo sorteado

  HeroModel? selectedHero; // Herói escalado pelo jogador
  String? result; // 'VITÓRIA', 'DERROTA' ou 'EMPATE'
  int? heroScore;
  int? enemyScore;

  MissionRound({
    required this.roundNumber,
    required this.attributeName,
    required this.statKey,
    required this.enemy,
  });
}

// Tela 5: Central Tática de Missões e Simulação de Combate
class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  late final HeroRepositoryImpl _repo;
  List<HeroModel> _squad = [];
  bool _isLoading = true;

  // Estado da Missão em andamento
  bool _missionActive = false;
  List<MissionRound> _rounds = [];
  int _currentRoundIndex = 0;
  final Set<int> _usedHeroIds = {}; // Bloqueia agente já usado em round anterior
  HeroModel? _currentlySelectedHero;
  bool _roundResolved = false;

  // Placar da Missão
  int _victories = 0;
  int _defeats = 0;
  int _draws = 0;
  final List<HeroModel> _winningHeroes = []; // Heróis que venceram rounds

  // Atributos possíveis para disputa
  final List<Map<String, String>> _possibleAttributes = [
    {'name': 'Inteligência', 'key': 'intelligence'},
    {'name': 'Força', 'key': 'strength'},
    {'name': 'Velocidade', 'key': 'speed'},
    {'name': 'Durabilidade', 'key': 'durability'},
    {'name': 'Poder', 'key': 'power'},
    {'name': 'Combate', 'key': 'combat'},
  ];

  @override
  void initState() {
    super.initState();
    _repo = Provider.of<HeroRepositoryImpl>(context, listen: false);
    _loadSquad();
  }

  Future<void> _loadSquad() async {
    setState(() => _isLoading = true);
    final squad = await _repo.getSquad();
    if (mounted) {
      setState(() {
        _squad = squad;
        _isLoading = false;
      });
    }
  }

  // Inicia um novo Desafio de Crise (sorteia de 3 a 5 rounds)
  Future<void> _startMission() async {
    if (_squad.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O esquadrão precisa ter pelo menos 5 agentes para iniciar uma Missão."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final random = Random();
    final totalRounds = random.nextInt(3) + 3; // Gera 3, 4 ou 5 rounds aleatoriamente

    final squadIds = _squad.map((h) => h.id).toList();
    final List<MissionRound> generatedRounds = [];

    for (int i = 0; i < totalRounds; i++) {
      // Sorteia o atributo dominante deste round
      final attr = _possibleAttributes[random.nextInt(_possibleAttributes.length)];

      // Sorteia inimigo garantindo que NÃO esteja no esquadrão do usuário
      final enemy = await _repo.getRandomEnemy(squadIds);
      if (enemy != null) {
        generatedRounds.add(
          MissionRound(
            roundNumber: i + 1,
            attributeName: attr['name']!,
            statKey: attr['key']!,
            enemy: enemy,
          ),
        );
      }
    }

    if (generatedRounds.isEmpty) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro ao carregar oponentes. Verifique a conexão com o servidor."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _rounds = generatedRounds;
      _currentRoundIndex = 0;
      _usedHeroIds.clear();
      _currentlySelectedHero = null;
      _roundResolved = false;
      _victories = 0;
      _defeats = 0;
      _draws = 0;
      _winningHeroes.clear();
      _missionActive = true;
      _isLoading = false;
    });
  }

  // Confirmação do agente escolhido e Resolução do confronto
  void _resolveRound() {
    if (_currentlySelectedHero == null) return;

    final currentRound = _rounds[_currentRoundIndex];
    final heroStat = _currentlySelectedHero!.getStatValue(currentRound.statKey);
    final enemyStat = currentRound.enemy.getStatValue(currentRound.statKey);

    currentRound.selectedHero = _currentlySelectedHero;
    currentRound.heroScore = heroStat;
    currentRound.enemyScore = enemyStat;
    _usedHeroIds.add(_currentlySelectedHero!.id);

    // Regras de resolução descritas no slide 11:
    // Herói > Inimigo = Sucesso na Rodada
    // Herói < Inimigo = Falha na Rodada
    // Valores Iguais = Empate tático
    if (heroStat > enemyStat) {
      currentRound.result = 'VITÓRIA';
      _victories++;
      _winningHeroes.add(_currentlySelectedHero!);
    } else if (heroStat < enemyStat) {
      currentRound.result = 'DERROTA';
      _defeats++;
    } else {
      currentRound.result = 'EMPATE';
      _draws++;
    }

    setState(() {
      _roundResolved = true;
    });
  }

  // Avança para o próximo round ou conclui a missão
  void _nextRoundOrFinish() {
    if (_currentRoundIndex + 1 < _rounds.length) {
      setState(() {
        _currentRoundIndex++;
        _currentlySelectedHero = null;
        _roundResolved = false;
      });
    } else {
      // Missão concluída! Dispara feedback final com awesome_dialog (slide 13)
      _finishMission();
    }
  }

  // Fim da missão e disparo do AwesomeDialog personalizado
  Future<void> _finishMission() async {
    final totalRounds = _rounds.length;
    final bool wonCampaign = _victories > (totalRounds / 2);

    if (wonCampaign) {
      // Vitória: Sorteia um dos heróis vitoriosos para ganhar +1 em atributo aleatório
      final random = Random();
      final rewardedHero = _winningHeroes.isNotEmpty
          ? _winningHeroes[random.nextInt(_winningHeroes.length)]
          : _squad[random.nextInt(_squad.length)];

      final randomStat = _possibleAttributes[random.nextInt(_possibleAttributes.length)];
      await _repo.updateSquadHeroStat(rewardedHero.id, randomStat['key']!);

      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Missão Cumprida!',
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              const Text(
                'Vitória Tática do Esquadrão!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Placar Final: $_victories Vitórias • $_defeats Derrotas • $_draws Empates',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              // Imagem do herói premiado (slide 13)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 100,
                  height: 120,
                  child: CachedNetworkImage(
                    imageUrl: rewardedHero.imageSm,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(Icons.person, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                rewardedHero.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                '+1 de Bônus em ${randomStat['name']}!',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        btnOkText: 'Continuar',
        btnOkOnPress: () {
          setState(() => _missionActive = false);
          _loadSquad();
        },
      ).show();
    } else {
      // Derrota: DialogType.error informando Operação Fracassada (slide 13)
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Operação Fracassada!',
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Icon(Icons.gpp_bad, size: 60, color: Colors.red),
              const SizedBox(height: 8),
              const Text(
                'O Esquadrão foi superado pelas ameaças!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Placar: $_victories Vitórias • $_defeats Derrotas • $_draws Empates',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        btnOkText: 'Voltar ao QG',
        btnOkColor: Colors.red.shade800,
        btnOkOnPress: () {
          setState(() => _missionActive = false);
        },
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_missionActive ? "Missão em Andamento" : "Central Tática de Missões"),
        leading: _missionActive
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: "Abandonar Missão",
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.question,
                    title: "Abandonar Missão?",
                    desc: "O progresso deste combate será perdido.",
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      setState(() => _missionActive = false);
                    },
                  ).show();
                },
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_missionActive
              ? _buildPreMissionScreen()
              : _buildBattleScreen(),
    );
  }

  // Tela Inicial da Missão (Pré-combate)
  Widget _buildPreMissionScreen() {
    final hasEnoughAgents = _squad.length >= 5;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.military_tech_rounded,
              size: 90,
              color: hasEnoughAgents ? Colors.amber.shade700 : Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              "Simulador Tático de Crise",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Teste a estratégia do seu esquadrão contra ameaças do sistema em um Desafio de Crise de 3 a 5 rounds.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            // Card de requisitos de agentes (Mínimo de 5 agentes)
            Card(
              elevation: 3,
              color: hasEnoughAgents ? Colors.green.shade50 : Colors.red.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      hasEnoughAgents ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: hasEnoughAgents ? Colors.green : Colors.red,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasEnoughAgents ? "Esquadrão Apto para Missão" : "Agentes Insuficientes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: hasEnoughAgents ? Colors.green.shade900 : Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Você possui ${_squad.length} / 5 agentes mínimos necessários.",
                            style: TextStyle(
                              fontSize: 13,
                              color: hasEnoughAgents ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botão Iniciar Missão
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasEnoughAgents ? Colors.deepPurple : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  "Iniciar Missão Tática",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: hasEnoughAgents ? _startMission : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tela de Batalha (Confronto da Rodada)
  Widget _buildBattleScreen() {
    final round = _rounds[_currentRoundIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Placar e Indicador do Round
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Round ${round.roundNumber} de ${_rounds.length}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "V: $_victories  |  D: $_defeats  |  E: $_draws",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Card de Apresentação do Desafio (Inimigo e Atributo em Disputa)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade700),
                    ),
                    child: Text(
                      "DISPUTA EM: ${round.attributeName.toUpperCase()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Inimigo da Rodada (Exibe imagem e nome, SEM mostrar atributos conforme slide 11)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 80,
                          height: 100,
                          child: CachedNetworkImage(
                            imageUrl: round.enemy.imageSm,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(Icons.person, size: 50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Inimigo da Rodada:",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            round.enemy.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _roundResolved
                                ? "${round.attributeName}: ${round.enemyScore}"
                                : "Atributos ocultos ???",
                            style: TextStyle(
                              color: _roundResolved ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Se a rodada já foi resolvida, exibe o resultado do combate
          if (_roundResolved) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: round.result == 'VITÓRIA'
                    ? Colors.green.shade100
                    : round.result == 'DERROTA'
                        ? Colors.red.shade100
                        : Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: round.result == 'VITÓRIA'
                      ? Colors.green
                      : round.result == 'DERROTA'
                          ? Colors.red
                          : Colors.amber,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    round.result!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: round.result == 'VITÓRIA'
                          ? Colors.green.shade900
                          : round.result == 'DERROTA'
                              ? Colors.red.shade900
                              : Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${round.selectedHero!.name} (${round.heroScore}) vs ${round.enemy.name} (${round.enemyScore})",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _nextRoundOrFinish,
              child: Text(
                _currentRoundIndex + 1 < _rounds.length ? "Próximo Round" : "Ver Resultado da Missão",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ] else ...[
            // Escalação: Seleção do Herói do Esquadrão
            const Text(
              "Escalar Agente para a Rodada:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Cada agente só pode lutar uma vez por missão.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Grid 3x5 de miniaturas com imagem circular e nome (conforme slide 11)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _squad.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 colunas
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final hero = _squad[index];
                final isUsed = _usedHeroIds.contains(hero.id);
                final isSelected = _currentlySelectedHero?.id == hero.id;

                return InkWell(
                  onTap: isUsed
                      ? null
                      : () {
                          setState(() {
                            _currentlySelectedHero = hero;
                          });
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepPurple.shade100
                          : isUsed
                              ? Colors.grey.shade200
                              : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepPurple
                            : isUsed
                                ? Colors.grey.shade400
                                : Colors.grey.shade300,
                        width: isSelected ? 2.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Imagem circular da miniatura
                        Opacity(
                          opacity: isUsed ? 0.4 : 1.0,
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: CachedNetworkImageProvider(hero.imageSm),
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Nome do agente
                        Text(
                          hero.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isUsed ? Colors.grey : Colors.black87,
                          ),
                        ),
                        if (isUsed)
                          const Text(
                            "Em combate",
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          )
                        else
                          Text(
                            "${round.attributeName}: ${hero.getStatValue(round.statKey)}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Botão Confirmar Agente
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentlySelectedHero != null ? Colors.red.shade700 : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.flash_on),
                label: Text(
                  _currentlySelectedHero != null
                      ? "Batalhar com ${_currentlySelectedHero!.name}"
                      : "Selecione um Agente",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _currentlySelectedHero != null ? _resolveRound : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
