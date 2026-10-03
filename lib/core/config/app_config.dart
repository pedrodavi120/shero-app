import 'dart:io';
import 'package:flutter/foundation.dart';

// Configuração externa e centralizada da URL da API (sem poluir a interface do app)
class AppConfig {
  // URL HTTPS oficial do Web Service ativo no Render
  static const String customApiUrl = "https://shero-app.onrender.com";

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
