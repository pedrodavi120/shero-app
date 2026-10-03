import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository_impl.dart';
import '../../domain/hero_model.dart';

// Tela de Detalhes do Agente (Catálogo Geral)
class AgentDetailsPage extends StatefulWidget {
  final int heroId;
  final HeroModel? initialHero;

  const AgentDetailsPage({
    super.key,
    required this.heroId,
    this.initialHero,
  });

  @override
  State<AgentDetailsPage> createState() => _AgentDetailsPageState();
}

class _AgentDetailsPageState extends State<AgentDetailsPage> {
  late Future<HeroModel> _heroFuture;
  late final HeroRepositoryImpl _repo;
  bool _isInSquad = false;
  int _squadCount = 0;

  @override
  void initState() {
    super.initState();
    _repo = Provider.of<HeroRepositoryImpl>(context, listen: false);

    // Carrega os dados preferencialmente da API ou do cache SQLite em caso offline
    _heroFuture = _repo.getHeroById(widget.heroId);
    _checkSquadStatus();
  }

  Future<void> _checkSquadStatus() async {
    final inSquad = await _repo.isInSquad(widget.heroId);
    final count = await _repo.getSquadCount();
    if (mounted) {
      setState(() {
        _isInSquad = inSquad;
        _squadCount = count;
      });
    }
  }

  Future<void> _recruitHero(HeroModel hero) async {
    if (_squadCount >= 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O esquadrão atingiu a capacidade máxima (15 agentes)!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _repo.addToSquad(hero);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${hero.name} foi recrutado para o Esquadrão!"),
          backgroundColor: Colors.green,
        ),
      );
      _checkSquadStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<HeroModel>(
        initialData: widget.initialHero,
        future: _heroFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final hero = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // Barra superior com imagem em alta resolução usando cached_network_image
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    hero.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 8, color: Colors.black, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: hero.imageLg.isNotEmpty ? hero.imageLg : hero.imageMd,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.blueGrey,
                          child: const Icon(Icons.person, size: 80, color: Colors.white70),
                        ),
                      ),
                      // Gradiente para destacar o título e os botões
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black45,
                              Colors.transparent,
                              Colors.black87,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Conteúdo detalhado com todas as informações da API
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botão de recrutamento caso ainda haja vaga
                      if (!_isInSquad)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.group_add),
                            label: Text(
                              _squadCount >= 15
                                  ? "Esquadrão Cheio (15/15)"
                                  : "Recrutar para o Esquadrão ($_squadCount/15)",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _squadCount >= 15 ? null : () => _recruitHero(hero),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                "Membro do seu Esquadrão",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Seção Powerstats com primer_progress_bar
                      _buildSectionTitle("Atributos de Combate (Powerstats)", Icons.bolt),
                      const SizedBox(height: 8),
                      _buildPowerstatBar("Inteligência", hero.intelligence, Colors.blue),
                      _buildPowerstatBar("Força", hero.strength, Colors.red),
                      _buildPowerstatBar("Velocidade", hero.speed, Colors.orange),
                      _buildPowerstatBar("Durabilidade", hero.durability, Colors.green),
                      _buildPowerstatBar("Poder", hero.power, Colors.purple),
                      _buildPowerstatBar("Combate", hero.combat, Colors.deepOrange),

                      const SizedBox(height: 24),

                      // Seção Biografia
                      _buildSectionTitle("Biografia", Icons.menu_book),
                      _buildInfoRow("Nome Completo", hero.fullName),
                      _buildInfoRow("Alter Egos", hero.alterEgos),
                      _buildInfoRow("Codinomes / Aliases", hero.aliases),
                      _buildInfoRow("Local de Nascimento", hero.placeOfBirth),
                      _buildInfoRow("Primeira Aparição", hero.firstAppearance),
                      _buildInfoRow("Editora", hero.publisher),
                      _buildInfoRow("Alinhamento", hero.alignment),

                      const SizedBox(height: 20),

                      // Seção Aparência
                      _buildSectionTitle("Aparência Física", Icons.accessibility_new),
                      _buildInfoRow("Gênero", hero.gender),
                      _buildInfoRow("Raça", hero.race),
                      _buildInfoRow("Altura", hero.height),
                      _buildInfoRow("Peso", hero.weight),
                      _buildInfoRow("Cor dos Olhos", hero.eyeColor),
                      _buildInfoRow("Cor do Cabelo", hero.hairColor),

                      const SizedBox(height: 20),

                      // Seção Trabalho e Base
                      _buildSectionTitle("Ocupação e Base", Icons.work),
                      _buildInfoRow("Ocupação", hero.occupation),
                      _buildInfoRow("Base de Operações", hero.base),

                      const SizedBox(height: 20),

                      // Seção Conexões e Relações
                      _buildSectionTitle("Conexões e Relações", Icons.people_outline),
                      _buildInfoRow("Grupos e Afiliações", hero.groupAffiliation),
                      _buildInfoRow("Parentes", hero.relatives),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Título visual de cada categoria
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Linha de detalhe de texto
  Widget _buildInfoRow(String label, String value) {
    final cleanValue = value.trim().isEmpty ? "-" : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              cleanValue,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Exibe cada powerstat usando a biblioteca primer_progress_bar exigida no PDF
  Widget _buildPowerstatBar(String label, int value, Color color) {
    final clampedVal = value.clamp(0, 100);
    final remaining = 100 - clampedVal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                "$clampedVal / 100",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Uso da biblioteca primer_progress_bar
          PrimerProgressBar(
            maxTotalValue: 100,
            segments: [
              Segment(
                value: clampedVal,
                color: color,
                label: Text(label),
                formattedValue: Text("$clampedVal"),
              ),
              Segment(
                value: remaining,
                color: Colors.grey.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
