import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository_impl.dart';
import '../../domain/hero_model.dart';
import '../widgets/hero_card.dart';
import 'agent_details_page.dart';

// Tela 1: Catálogo Geral de Agentes com Paginação Infinita e Offline-First
class AgentsCatalogPage extends StatefulWidget {
  const AgentsCatalogPage({super.key});

  @override
  State<AgentsCatalogPage> createState() => _AgentsCatalogPageState();
}

class _AgentsCatalogPageState extends State<AgentsCatalogPage> {
  static const int _pageSize = 15;

  late final HeroRepositoryImpl _heroRepo;

  // Controlador de paginação da biblioteca infinite_scroll_pagination
  final PagingController<int, HeroModel> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _heroRepo = Provider.of<HeroRepositoryImpl>(context, listen: false);

    // Adiciona o ouvinte para carregar mais páginas conforme o usuário rola a lista
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  // Busca uma página da API/Cache SQLite e anexa na lista
  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _heroRepo.getHeroes(page: pageKey, limit: _pageSize);
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Agentes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Recarregar Lista",
            onPressed: () => _pagingController.refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, HeroModel>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<HeroModel>(
            itemBuilder: (context, hero, index) => HeroCard(
              hero: hero,
              onTap: () {
                // Ao clicar no card, abre a tela de Detalhes do Agente
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AgentDetailsPage(
                      heroId: hero.id,
                      initialHero: hero,
                    ),
                  ),
                );
              },
            ),
            firstPageProgressIndicatorBuilder: (_) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Carregando agentes da agência..."),
                ],
              ),
            ),
            newPageProgressIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            noItemsFoundIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Nenhum agente encontrado.\nVerifique a conexão ou inicie o servidor.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
