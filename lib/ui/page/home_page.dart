import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository_impl.dart';
import 'agents_catalog_page.dart';
import 'daily_contract_page.dart';
import 'missions_page.dart';
import 'my_squad_page.dart';

// Tela Inicial do Aplicativo conforme exigido no slide 4 do PDF.
// Fornece navegação para: Agentes, Contrato Diário, Meu Esquadrão e Missões.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _squadCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshSquadCount();
  }

  Future<void> _refreshSquadCount() async {
    final repo = Provider.of<HeroRepositoryImpl>(context, listen: false);
    final count = await repo.getSquadCount();
    if (mounted) {
      setState(() => _squadCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SHERO",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Chip(
              avatar: const Icon(Icons.shield, size: 16, color: Colors.amber),
              label: Text(
                "$_squadCount/15",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner de boas-vindas da agência
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade800, Colors.indigo.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: Colors.black,
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              'assets/images/logoshero.png',
                              height: 36,
                              width: 36,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "CENTRAL DE COMANDO",
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Gerenciador de Super-Heróis",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Recrute agentes para o seu esquadrão, gerencie atributos e envie sua equipe para simulações de combate e missões táticas.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Módulos Operacionais",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // Botão 1: Agentes (Catálogo Geral)
              _buildMenuCard(
                title: "Agentes",
                subtitle: "Catálogo completo com todos os heróis da API e busca em cache",
                icon: Icons.people_alt,
                color: Colors.blue.shade700,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AgentsCatalogPage()),
                  );
                  _refreshSquadCount();
                },
              ),

              const SizedBox(height: 14),

              // Botão 2: Contrato Diário (Recrutamento 1x ao dia)
              _buildMenuCard(
                title: "Contrato Diário",
                subtitle: "Convocação diária de heróis para recrutar novos membros",
                icon: Icons.calendar_month,
                color: Colors.amber.shade800,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DailyContractPage()),
                  );
                  _refreshSquadCount();
                },
              ),

              const SizedBox(height: 14),

              // Botão 3: Meu Esquadrão (Equipe com até 15 agentes)
              _buildMenuCard(
                title: "Meu Esquadrão",
                subtitle: "Gerencie sua equipe tática ($_squadCount de 15 agentes)",
                icon: Icons.shield,
                color: Colors.teal.shade700,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MySquadPage()),
                  );
                  _refreshSquadCount();
                },
              ),

              const SizedBox(height: 14),

              // Botão 4: Missões (Simulação de combate tático)
              _buildMenuCard(
                title: "Missões",
                subtitle: "Simulador de combate tático e desafios de crise",
                icon: Icons.crisis_alert,
                color: Colors.red.shade700,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MissionsPage()),
                  );
                  _refreshSquadCount();
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Card de menu interativo estilizado
  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
