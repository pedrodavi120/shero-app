import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository_impl.dart';
import '../../domain/hero_model.dart';
import '../widgets/hero_card.dart';
import 'squad_agent_details_page.dart';

// Tela 3: Meu Esquadrão
// Lista exclusivamente os agentes salvos no SQLite (máximo 15)
class MySquadPage extends StatefulWidget {
  const MySquadPage({super.key});

  @override
  State<MySquadPage> createState() => _MySquadPageState();
}

class _MySquadPageState extends State<MySquadPage> {
  late final HeroRepositoryImpl _repo;
  List<HeroModel> _squad = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = Provider.of<HeroRepositoryImpl>(context, listen: false);
    _loadSquad();
  }

  // Busca a lista atualizada do esquadrão no SQLite
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Esquadrão"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_squad.length} / 15 Agentes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _squad.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, size: 70, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          "Seu Esquadrão ainda está vazio!",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Recrute novos heróis no Contrato Diário ou no Catálogo de Agentes para participar das Missões (mínimo de 5 agentes).",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSquad,
                  child: ListView.builder(
                    itemCount: _squad.length,
                    itemBuilder: (context, index) {
                      final hero = _squad[index];
                      return HeroCard(
                        hero: hero,
                        // Exibe o papel tático e o maior atributo conforme pedido no slide 8
                        subtitleOverride: "Papel: ${hero.tacticalRole} • ${hero.highestStatName}",
                        onTap: () async {
                          // Navega para a tela Detalhes do Meu Agente
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SquadAgentDetailsPage(hero: hero),
                            ),
                          );
                          // Atualiza a lista caso o agente tenha sido dispensado
                          _loadSquad();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
