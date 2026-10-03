import 'dart:io';
import 'package:flutter/foundation.dart';

// Configuração externa e centralizada da URL da API (sem poluir a interface do app)
class AppConfig {
  // Cole aqui a URL HTTPS do seu Web Service criado no Render:
  // Exemplo: static const String customApiUrl = "https://shero-app-api.onrender.com";
  // Se deixar vazio (""), o app tentará o emulador Android (10.0.2.2) ou o espelho oficial de contingência.
  static const String customApiUrl = "";

  // Suporte a injeção via parâmetro de build: flutter build apk --dart-define=API_URL=https://sua-api.onrender.com
  static const String _envUrl = String.fromEnvironment('API_URL');

  static String getBaseUrl() {
    if (_envUrl.isNotEmpty) {
      return _envUrl;
    }
    if (customApiUrl.isNotEmpty) {
      return customApiUrl;
    }
    if (!kIsWeb && Platform.isAndroid) {
      return "http://10.0.2.2:3000";
    }
    return "http://localhost:3000";
  }
}
