import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/hero_model.dart';

// Card reutilizável para exibir informações resumidas do herói no catálogo e no esquadrão
class HeroCard extends StatelessWidget {
  final HeroModel hero;
  final VoidCallback? onTap;
  final String? subtitleOverride; // Permite exibir papel tático ou maior atributo no esquadrão

  const HeroCard({
    super.key,
    required this.hero,
    this.onTap,
    this.subtitleOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Miniatura com cache usando cached_network_image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 75,
                  height: 95,
                  child: hero.imageSm.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: hero.imageSm,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person, size: 40, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person, size: 40, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Informações do herói (Nome, Appearance e Powerstats)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Subtítulo customizado (usado no esquadrão) ou detalhes de aparência
                    if (subtitleOverride != null)
                      Text(
                        subtitleOverride!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    else ...[
                      // Mostra resumo de aparência (gênero / raça)
                      Text(
                        "${hero.gender} • ${hero.race.isNotEmpty && hero.race != '-' ? hero.race : 'Origem Oculta'}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Chips rápidos com alguns powerstats principais
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildStatBadge("FOR", hero.strength, Colors.red.shade700),
                          _buildStatBadge("INT", hero.intelligence, Colors.blue.shade700),
                          _buildStatBadge("VEL", hero.speed, Colors.amber.shade800),
                          _buildStatBadge("POD", hero.power, Colors.purple.shade700),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para desenhar crachás de atributos no card
  Widget _buildStatBadge(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
