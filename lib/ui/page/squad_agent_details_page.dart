import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository_impl.dart';
import '../../domain/hero_model.dart';

// Tela 4: Detalhes do Meu Agente
// Exibe a carta do herói recrutado com opção de dispensar via awesome_dialog
class SquadAgentDetailsPage extends StatefulWidget {
  final HeroModel hero;

  const SquadAgentDetailsPage({super.key, required this.hero});

  @override
  State<SquadAgentDetailsPage> createState() => _SquadAgentDetailsPageState();
}

class _SquadAgentDetailsPageState extends State<SquadAgentDetailsPage> {
  late final HeroRepositoryImpl _repo;

  @override
  void initState() {
    super.initState();
    _repo = Provider.of<HeroRepositoryImpl>(context, listen: false);
  }

  // Confirmação para dispensar o herói usando a biblioteca obrigatória awesome_dialog
  void _confirmDismissHero() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Dispensar Agente',
      desc: 'Tem certeza que deseja dispensar ${widget.hero.name} do seu esquadrão? Uma vaga será liberada na equipe.',
      btnCancelText: 'Cancelar',
      btnOkText: 'Dispensar',
      btnOkColor: Colors.red.shade700,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await _repo.removeFromSquad(widget.hero.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${widget.hero.name} foi dispensado do esquadrão."),
              backgroundColor: Colors.orange.shade800,
            ),
          );
          Navigator.of(context).pop();
        }
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner do Herói
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                hero.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
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
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Informações detalhadas e botão de Dispensar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de Informações Táticas do Esquadrão
                  Card(
                    color: Colors.blueGrey.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.military_tech, color: Colors.amber, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Papel Tático: ${hero.tacticalRole}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Maior Atributo: ${hero.highestStatName}",
                                  style: const TextStyle(color: Colors.amberAccent, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botão Dispensar do Esquadrão (conforme slide 9)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.person_remove),
                      label: const Text(
                        "Dispensar do Esquadrão",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _confirmDismissHero,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Powerstats com primer_progress_bar
                  _buildSectionHeader("Powerstats do Agente", Icons.bolt),
                  const SizedBox(height: 8),
                  _buildStatBar("Inteligência", hero.intelligence, Colors.blue),
                  _buildStatBar("Força", hero.strength, Colors.red),
                  _buildStatBar("Velocidade", hero.speed, Colors.orange),
                  _buildStatBar("Durabilidade", hero.durability, Colors.green),
                  _buildStatBar("Poder", hero.power, Colors.purple),
                  _buildStatBar("Combate", hero.combat, Colors.deepOrange),

                  const SizedBox(height: 24),

                  // Biografia completa
                  _buildSectionHeader("Ficha de Identificação", Icons.badge),
                  _buildDataRow("Nome Real", hero.fullName),
                  _buildDataRow("Codinomes", hero.aliases),
                  _buildDataRow("Alinhamento", hero.alignment),
                  _buildDataRow("Editora", hero.publisher),
                  _buildDataRow("Nascimento", hero.placeOfBirth),
                  _buildDataRow("Primeira Aparição", hero.firstAppearance),

                  const SizedBox(height: 20),

                  // Conexões e Trabalho
                  _buildSectionHeader("Ocupação e Afiliações", Icons.business_center),
                  _buildDataRow("Ocupação", hero.occupation),
                  _buildDataRow("Base", hero.base),
                  _buildDataRow("Grupos", hero.groupAffiliation),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    final clamped = value.clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text("$clamped / 100", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          PrimerProgressBar(
            maxTotalValue: 100,
            segments: [
              Segment(value: clamped, color: color),
              Segment(value: 100 - clamped, color: Colors.grey.shade200),
            ],
          ),
        ],
      ),
    );
  }
}
