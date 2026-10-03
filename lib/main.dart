import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/configure_providers.dart';
import 'ui/page/home_page.dart';

// Ponto de entrada do aplicativo SHERO (Projeto de PDM - UFRN)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o grafo de dependências (SQLite, SharedPreferences, ApiClient, Repositories)
  final data = await ConfigureProviders.createDependencyTree();

  runApp(AppRoot(data: data));
}

class AppRoot extends StatelessWidget {
  final ConfigureProviders data;

  const AppRoot({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: data.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SHERO • Agência Tática',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}