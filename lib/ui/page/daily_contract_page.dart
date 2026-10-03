import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository_impl.dart';
import '../../domain/hero_model.dart';

// Tela 2: Contrato Diário (Recrutamento)
// Exibe um herói sorteado uma vez ao dia com nome, imagem e powerstats
class DailyContractPage extends StatefulWidget {
  const DailyContractPage({super.key});

  @override
  State<DailyContractPage> createState() => _DailyContractPageState();
}

class _DailyContractPageState extends State<DailyContractPage> {
  late final HeroRepositoryImpl _repo;
  HeroModel? _dailyHero;
  bool _isLoading = true;
  bool _isInSquad = false;
  int _squadCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repo = Provider.of<HeroRepositoryImpl>(context, listen: false);
    _loadDailyContract();
  }

  // Carrega o herói do dia usando SharedPreferences
  Future<void> _loadDailyContract({bool forceNew = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hero = await _repo.getDailyHero(forceNew: forceNew);
      final inSquad = await _repo.isInSquad(hero.id);
      final squadCount = await _repo.getSquadCount();

      if (mounted) {
        setState(() {
          _dailyHero = hero;
          _isInSquad = inSquad;
          _squadCount = squadCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erro ao convocar herói do dia: $e";
          _isLoading = false;
        });
      }
    }
  }

  // Ação do botão "Recrutar para o Esquadrão"
  Future<void> _recruitToSquad() async {
    if (_dailyHero == null) return;

    if (_squadCount >= 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O esquadrão atingiu a capacidade máxima de 15 agentes!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _repo.addToSquad(_dailyHero!);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_dailyHero!.name} foi integrado com sucesso ao Esquadrão!"),
          backgroundColor: Colors.green,
        ),
      );
      // Atualiza o estado
      setState(() {
        _isInSquad = true;
        _squadCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contrato Diário"),
        actions: [
          // Botão auxiliar útil para testes do professor e apresentação
          IconButton(
            icon: const Icon(Icons.casino),
            tooltip: "Simular Novo Dia (Sorteio)",
            onPressed: () => _loadDailyContract(forceNew: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadDailyContract(),
                          child: const Text("Tentar Novamente"),
                        ),
                      ],
                    ),
                  ),
                )
              : _dailyHero == null
                  ? const Center(child: Text("Nenhum contrato disponível hoje."))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Banner explicativo simples
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade700),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_filled, color: Colors.amber.shade900),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "Novo contrato disponível a cada 24 horas. Recrute para fortalecer sua equipe!",
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Card do herói: Deve conter APENAS nome, imagem e power stats (conforme PDF slide 7)
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // Imagem do herói
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      height: 260,
                                      width: double.infinity,
                                      child: CachedNetworkImage(
                                        imageUrl: _dailyHero!.imageLg.isNotEmpty
                                            ? _dailyHero!.imageLg
                                            : _dailyHero!.imageMd,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.person, size: 80),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Nome do herói
                                  Text(
                                    _dailyHero!.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Divider(height: 24),

                                  // Power Stats (exibidos com barras)
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Power Stats:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  _buildStatBar("Inteligência", _dailyHero!.intelligence, Colors.blue),
                                  _buildStatBar("Força", _dailyHero!.strength, Colors.red),
                                  _buildStatBar("Velocidade", _dailyHero!.speed, Colors.orange),
                                  _buildStatBar("Durabilidade", _dailyHero!.durability, Colors.green),
                                  _buildStatBar("Poder", _dailyHero!.power, Colors.purple),
                                  _buildStatBar("Combate", _dailyHero!.combat, Colors.deepOrange),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Botão "Recrutar para o Esquadrão"
                          SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isInSquad ? Colors.grey : Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(_isInSquad ? Icons.check : Icons.person_add),
                              label: Text(
                                _isInSquad
                                    ? "Agente Já Recrutado"
                                    : _squadCount >= 15
                                        ? "Esquadrão Lotado (15/15)"
                                        : "Recrutar para o Esquadrão ($_squadCount/15)",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              // Se já tiver 15 agentes ou já estiver no esquadrão, desabilita
                              onPressed: (_isInSquad || _squadCount >= 15) ? null : _recruitToSquad,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }

  // Barra de atributo com primer_progress_bar
  Widget _buildStatBar(String name, int value, Color color) {
    final clamped = value.clamp(0, 100);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 13)),
              Text("$clamped", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 3),
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
