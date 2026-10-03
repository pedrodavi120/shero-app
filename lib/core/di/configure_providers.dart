import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

import '../../data/database/dao/hero_dao.dart';
import '../../data/database/dao/squad_dao.dart';
import '../../data/database/database_mapper.dart';
import '../../data/network/client/api_client.dart';
import '../../data/network/network_mapper.dart';
import '../../data/repository/hero_repository_impl.dart';

// Configuração da injeção de dependências do app usando o padrão Provider ensinado em aula
class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  static Future<ConfigureProviders> createDependencyTree() async {
    // Inicializa o SharedPreferences para salvar o contrato diário
    final sharedPreferences = await SharedPreferences.getInstance();

    final baseUrl = AppConfig.getBaseUrl();
    final apiClient = ApiClient(baseUrl: baseUrl);
    final networkMapper = NetworkMapper();
    final databaseMapper = DatabaseMapper();
    final heroDao = HeroDao();
    final squadDao = SquadDao();

    final heroRepository = HeroRepositoryImpl(
      apiClient: apiClient,
      networkMapper: networkMapper,
      databaseMapper: databaseMapper,
      heroDao: heroDao,
      squadDao: squadDao,
      sharedPreferences: sharedPreferences,
    );

    return ConfigureProviders(
      providers: [
        Provider<SharedPreferences>.value(value: sharedPreferences),
        Provider<ApiClient>.value(value: apiClient),
        Provider<NetworkMapper>.value(value: networkMapper),
        Provider<DatabaseMapper>.value(value: databaseMapper),
        Provider<HeroDao>.value(value: heroDao),
        Provider<SquadDao>.value(value: squadDao),
        Provider<HeroRepositoryImpl>.value(value: heroRepository),
      ],
    );
  }
}
