import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/exception/network_exception.dart';
import '../entity/hero_network_entity.dart';

// Cliente HTTP responsável por se comunicar com o json-server simulando a API REST.
class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  
  // URL de contingência caso o json-server local não esteja iniciado na hora do teste
  static const String fallbackUrl = "https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json";

  ApiClient({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    )..interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
        ),
      );
  }

  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  // Busca heróis paginados usando os parâmetros do json-server (_page e _per_page)
  Future<List<HeroNetworkEntity>> getHeroes({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        "/heroes",
        queryParameters: {
          '_page': page,
          '_per_page': limit,
        },
      );

      return _parseHeroesList(response.data);
    } catch (e) {
      // Se falhar a conexão com o servidor local (ex: rodando no celular sem ip fixo),
      // tentamos buscar do repositório original para salvar no cache!
      debugPrint("Aviso ApiClient: Não foi possível conectar ao json-server local ($e). Tentando fallback...");
      try {
        final fallbackDio = Dio();
        final fallbackResp = await fallbackDio.get(fallbackUrl);
        final List<dynamic> fullList = fallbackResp.data is String 
            ? jsonDecode(fallbackResp.data) 
            : fallbackResp.data;

        // Fazemos a paginação manual caso esteja usando a lista completa do fallback
        final startIndex = (page - 1) * limit;
        if (startIndex >= fullList.length) return [];
        final endIndex = (startIndex + limit > fullList.length) ? fullList.length : startIndex + limit;
        
        final sublist = fullList.sublist(startIndex, endIndex);
        return sublist.map((item) => HeroNetworkEntity.fromJson(item as Map<String, dynamic>)).toList();
      } catch (fallbackError) {
        throw NetworkException(
          statusCode: 500,
          message: "Erro de conexão com o servidor local e fallback: $fallbackError",
        );
      }
    }
  }

  // Busca todos os heróis (ótimo para alimentar o cache do SQLite na primeira execução)
  Future<List<HeroNetworkEntity>> getAllHeroes() async {
    try {
      final response = await _dio.get("/heroes");
      return _parseHeroesList(response.data);
    } catch (e) {
      final fallbackDio = Dio();
      final fallbackResp = await fallbackDio.get(fallbackUrl);
      final List<dynamic> fullList = fallbackResp.data is String 
          ? jsonDecode(fallbackResp.data) 
          : fallbackResp.data;
      return fullList.map((item) => HeroNetworkEntity.fromJson(item as Map<String, dynamic>)).toList();
    }
  }

  // Busca um herói específico pelo ID
  Future<HeroNetworkEntity> getHeroById(int id) async {
    try {
      final response = await _dio.get("/heroes/$id");
      return HeroNetworkEntity.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Se não encontrar ou o servidor estiver desligado, busca no cache geral
      final all = await getAllHeroes();
      return all.firstWhere((h) => h.id == id);
    }
  }

  // Trata tanto a resposta paginada do json-server v1 quanto uma lista direta
  List<HeroNetworkEntity> _parseHeroesList(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      final list = data['data'] as List<dynamic>;
      return list.map((item) => HeroNetworkEntity.fromJson(item as Map<String, dynamic>)).toList();
    } else if (data is List) {
      return data.map((item) => HeroNetworkEntity.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
